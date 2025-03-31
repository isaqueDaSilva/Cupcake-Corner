//
//  BagView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import WebSocket

// MARK: - Main View Model -
extension BagView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "BagView+ViewModel")
        
        private var ordersDictionary: [Status: [UUID: Order]] = [
            .ordered : [:],
            .readyForDelivery : [:]
        ]
        
        @ObservationIgnored
        private var wsService: WebSocketClient?
        
        @ObservationIgnored
        private var channelObserverTask: Task<Void, Never>?
        
        @ObservationIgnored
        private var connectionStatusTask: Task<Void, Never>?
        
        @ObservationIgnored
        private var waitingForDisconnectFromChannelTask: Task<Void, Never>?
        
        var isChannelConnected: Bool {
            let isConnected = channelObserverTask != nil && wsService != nil && connectionStatusTask != nil
            
            logger.info("Channel connection state: \(isConnected)")
            
            return isConnected
        }
        
        var orders: [Order] {
            
            let orders = ordersDictionary[statusType]?.toArray.sorted(by: {
                switch statusType {
                case .ordered:
                    return $0.orderTime < $1.orderTime
                case .readyForDelivery:
                    if let readyForDeliveryTime1 = $0.readyForDeliveryTime,
                       let readyForDeliveryTime2 = $1.readyForDeliveryTime {
                        
                        return readyForDeliveryTime1 < readyForDeliveryTime2
                    } else {
                        return false
                    }
                case .delivered:
                    return false
                }
            }) ?? []
            
            logger.info("Was found \(orders.count) orders for \(statusType.displayedName) status.")
            
            return orders
        }
        
        
        #if CLIENT
        var totalOfBag: Double {
            let finalPrice = ordersDictionary
                .toArray
                .reduce([], { $0 + $1.values })
                .reduce(0, { $0 + $1.finalPrice })
            
            logger.info("The final price for this bag is \(finalPrice.toCurreny).")
            
            return finalPrice
        }
        #endif
        
        var statusType: Status = .ordered
        var connectionStatus: WebSocketClient.ConnectionState = .disconnected {
            didSet {
                logger.info("A new connection was setted with success. Status: \(connectionStatus)")
            }
        }
        
        var isLoading = false
        var error: ExecutionError?
        
        init(isPreview: Bool = false) {
            
            if isPreview {
                #if DEBUG
                self.ordersDictionary = Order.mocksDict
                #endif
                self.connectionStatus = .connected
            } else {
                self.connect()
            }
        }
    }
}

// MARK: - Connect in channel -
extension BagView.ViewModel {
    func connect(with session: URLSession = .shared) {
        self.isLoading = true
        
        if waitingForDisconnectFromChannelTask != nil {
            removeDisconnectionRequest()
        }
        
        self.setWSService(with: session)
        
        Task { [weak self] in
            guard let self else { return }
            
            guard let wsService else {
                logger.error("The are no ws service to handle with the connection.")
                return await setError(.noConnection)
            }
            
            await wsService.connect()
            
            logger.info("The connection was established with success.")
            
            observerConnectionState()
            observerChangesInChannel()
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.isLoading = false
            }
        }
    }
    
    private func setWSService(with session: URLSession) {
        do {
            let token = try TokenGetter.getValue()
            configureService(with: token, session: session)
        } catch {
            Task { [weak self] in
                guard let self else { return }
                
                await setError(error)
            }
        }
    }
    
    private func configureService(with token: String, session: URLSession) {
        let endpoint = Endpoint(
            scheme: EndpointBuilder.webSocketSchema,
            host: EndpointBuilder.domainName,
            path: EndpointBuilder.makePath(endpoint: .order, path: .channel),
            httpMethod: .get,
            headers: [
                EndpointBuilder.Header.authorization.rawValue : token,
                EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.vdnAPIJSON.rawValue
            ]
        )
        
        let wsConfigurantion = WebSocketConfiguration(endpoint: endpoint)
        
        let wsService = WebSocketClient(
            configuration: wsConfigurantion,
            session: session
        )
        
        self.wsService = wsService
        
        self.logger.info("WSService was setted with success.")
    }
}

// MARK: - Disconnect from channel -
extension BagView.ViewModel {
    func disconnect(isWaitingForDisconnect: Bool) {
        self.waitingForDisconnectFromChannelTask = Task { [weak self] in
            guard let self else { return }
            
            await self.scheduleChannelDisconnection(isWaitingForDisconnect)
        }
    }
    
    private func removeDisconnectionRequest() {
        self.waitingForDisconnectFromChannelTask?.cancel()
        self.waitingForDisconnectFromChannelTask = nil
        logger.info("Disconnection channel request was removed with success.")
    }
    
    private func scheduleChannelDisconnection(_ isWaitingForDisconnect: Bool) async {
        if isWaitingForDisconnect {
            try? await Task.sleep(for: .seconds(300))
        }
        
        await wsService?.disconnect()
        self.wsService = nil
        self.channelObserverTask?.cancel()
        self.channelObserverTask = nil
        
        self.waitingForDisconnectFromChannelTask?.cancel()
        self.waitingForDisconnectFromChannelTask = nil
        
        logger.info("The channel's connection was removed with success.")
    }
}

// MARK: - Channel Messages Observation -
extension BagView.ViewModel {
    private func observerChangesInChannel() {
        channelObserverTask?.cancel()
        
        guard let wsService else { return }
        
        channelObserverTask = Task { @WebSocketActor [weak self] in
            guard let self else { return }
            
            do {
                for try await message in wsService.onReceiveMessageSubject.values {
                    switch message {
                    case .data(let data):
                        try await handleWithReceiveData(data)
                    case .string(_):
                        await disconnect(isWaitingForDisconnect: false)
                        throw ExecutionError.internalError
                    @unknown default:
                        break
                    }
                }
                
                await disconnect(isWaitingForDisconnect: false)
            } catch {
                await self.setError(
                    .init(
                        title: "Failed to receive message",
                        descrition: error.localizedDescription
                    )
                )
            }
        }
    }
    
    private func handleWithReceiveData(_ data: Data) async throws(ExecutionError) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let message = try Network.decodeResponse(
            type: WebSocketMessage.self,
            by: data,
            with: decoder
        )
        
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            switch message.data {
            case .newOrder(let newOrder):
                self.ordersDictionary[.ordered]?[newOrder.id] = newOrder
                
                logger.info("A new order was added with success in the list.")
            case .get(let orderList):
                self.ordersDictionary = orderList.list
                
                logger.info("The list was setted with success.")
            case .update(let updatedOrder):
                self.ordersDictionary[.ordered]?[updatedOrder.id] = nil
                
                self.ordersDictionary[.readyForDelivery]?[updatedOrder.id] = updatedOrder
                
                logger.info("An order was wupdated with success.")
            case .delivered(let orderID):
                self.ordersDictionary[.readyForDelivery]?[orderID] = nil
            }
            
        }
    }
}

// MARK: - Channel connection observation -
extension BagView.ViewModel {
    private func observerConnectionState() {
        connectionStatusTask?.cancel()
        
        guard let wsService else { return }
        
        connectionStatusTask = Task { @WebSocketActor [weak self] in
            guard let self else { return }
            
            for await connectionStatus in wsService.connectionStateSubject.values {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.connectionStatus = connectionStatus
                }
            }
        }
    }
}

// MARK: - Set Error -
extension BagView.ViewModel {
    private func setError(_ error: ExecutionError) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.error = .init(
                title: "Failed to receive message",
                descrition: error.localizedDescription
            )
            
            self.logger.info("A new error was setted. Error: Title -> \(error.title); Message: \(error.descrition).")
        }
    }
}

// MARK: - Update Order -
#if ADMIN
extension BagView.ViewModel {
    func updateOrder(for orderID: UUID, with currentStatus: Status, session: URLSession = .shared) {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let updatedOrder = try makeUpdatedOrder(from: currentStatus, orderID: orderID)
                let updatedOrderData = try Network.encodeData(updatedOrder)
                
                let (_, response) = try await getData(with: updatedOrderData, session: session)
                
                try Network.checkResponse(response)
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.error = .init(
                        title: "Failed to update order.",
                        descrition: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func getData(
        with updatedOrder: Data,
        session: URLSession
    ) async throws(ExecutionError) -> (Data, URLResponse) {
        let token = try TokenGetter.getValue()
        
        return try await Network.getData(
            path: EndpointBuilder.makePath(endpoint: .order, path: .update),
            httpMethod: .patch,
            headers: [
                EndpointBuilder.Header.contentType.rawValue: EndpointBuilder.HeaderValue.json.rawValue,
                EndpointBuilder.Header.authorization.rawValue : token
            ],
            body: updatedOrder,
            session: session
        )
    }
    
    private func makeUpdatedOrder(
        from currentStatus: Status,
        orderID: UUID
    ) throws(ExecutionError) -> Order.Update {
        let newStatus: Status = switch currentStatus {
        case .ordered:
            .readyForDelivery
        case .readyForDelivery:
            .delivered
        case .delivered:
            currentStatus
        }
        
        guard newStatus != currentStatus else {
            throw .init(
                title: "Update Error",
                descrition: "To update an order, the status cannot be the same."
            )
        }
        
        return .init(id: orderID, status: newStatus)
    }
}
#endif
