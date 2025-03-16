//
//  BagView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import WebSocketHandler

extension BagView {
    @Observable
    @MainActor
    final class ViewModel {
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
        
        var orders: [Order] {
            let orders = ordersDictionary[statusType]?.toArray ?? []
            
            print(ordersDictionary.count, orders.count)
            
            return orders
        }
        
        var totalOfBag: Double {
            orders.reduce(0, { $0 + $1.finalPrice })
        }
        
        var statusType: Status = .ordered
        var connectionStatus: WSConnectionState = .disconnected
        var isLoading = false
        var error: ExecutionError?
        
        func connect(with session: URLSession = .shared) {
            self.isLoading = true
            
            Task {
                do {
                    let token = try TokenGetter.getValue()
                    try await getInitialOrders(with: token, session: session)
                    await configureService(with: token, session: session)
                    
                    guard let wsService else { throw ExecutionError.noConnection }
                    
                    await MainActor.run {
                        self.isLoading = false
                    }
                    
                    observerConnection()
                    await wsService.connect()
                } catch let error as ExecutionError {
                    await MainActor.run {
                        self.error = error
                    }
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        func reconnect() {
            guard let wsService else { return }
            
            Task { @WebSocketActor [weak self] in
                guard self != nil else { return }
                
                wsService.reconnect()
            }
        }
        
        func disconnect() async {
            await wsService?.disconnect()
            self.channelObserverTask?.cancel()
            self.connectionStatusTask?.cancel()
            
            self.channelObserverTask = nil
            self.connectionStatusTask = nil
            self.wsService = nil
            
            await MainActor.run {
                self.connectionStatus = .disconnected
            }
        }
        
        private func getInitialOrders(
            with token: String,
            session: URLSession
        ) async throws(ExecutionError) {
            let ordersData = try await InitialDataGetter.getInitialOrders(
                with: token,
                session: session
            )
            
            let orders = try self.decode(type: [Order].self, by: ordersData)
            
            var ordersDictionary = [Status: [UUID: Order]]()
            
            orders.forEach { order in
                ordersDictionary[order.status]?.updateValue(
                    order,
                    forKey: order.id
                )
            }
            
            await MainActor.run {
                self.ordersDictionary = ordersDictionary
            }
        }
        
        private func configureService(with token: String, session: URLSession) async {
            let wsService = await WebSocketHandler.connectInChannel(with: token, session: session)
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.wsService = wsService
            }
        }
        
        private func observerChangesInChannel() {
            channelObserverTask?.cancel()
            
            guard let wsService else { return }
            
            channelObserverTask = Task {
                do {
                    for try await message in await wsService.onReceiveDataSubject.values {
                        switch message {
                        case .data(let data):
                            try await handleWithReceiveData(data)
                        case .string(_):
                            await disconnect()
                            throw ExecutionError.internalError
                        @unknown default:
                            break
                        }
                    }
                } catch let executionError as ExecutionError {
                    await MainActor.run {
                        self.error = executionError
                    }
                } catch {
                    await MainActor.run {
                        self.error = .init(
                            title: "Failed to receive message",
                            descrition: error.localizedDescription
                        )
                    }
                }
            }
        }
        
        private func handleWithReceiveData(_ data: Data) async throws(ExecutionError) {
            let message = try decode(type: WebSocketMessage<Receive>.self, by: data)
            
            switch message.data {
            case .newOrder(let newOrder):
                await MainActor.run {
                    _ = self.ordersDictionary[.ordered]?.updateValue(
                        newOrder,
                        forKey: newOrder.id
                    )
                }
            case .update(let order):
                await MainActor.run {
                    _ = self.ordersDictionary[.readyForDelivery]?.updateValue(
                        order,
                        forKey: order.id
                    )
                }
            }
        }
        
        private func observerConnection() {
            channelObserverTask?.cancel()
            
            guard let wsService else { return }
            
            self.channelObserverTask = Task {
                for await connectionStatus in await wsService.connectionStateSubject.values {
                    await MainActor.run {
                        self.connectionStatus = connectionStatus
                    }
                }
            }
        }
        
        private func decode<T: Decodable>(type: T.Type, by data: Data) throws(ExecutionError) -> T {
            guard let data = try? JSONDecoder().decode(T.self, from: data) else {
                throw .decodedFailure
            }
            
            return data
        }
        
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


#if ADMIN
extension BagView.ViewModel {
    func updateOrder(for orderID: UUID, with currentStatus: Status) {
        Task {
            do {
                guard let wsService else { throw ExecutionError.noConnection }
                
                let newStatus: Status = setNewStatus(from: currentStatus)
                
                guard newStatus != currentStatus else { return }
                
                let messageData = try makeMessageData(with: orderID, newStatus: newStatus)
                
                try await wsService.sendMessage(.data(messageData))
            } catch {
                await MainActor.run {
                    self.error = .init(
                        title: "Failed to update order.",
                        descrition: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func setNewStatus(from currentStatus: Status) -> Status {
        switch currentStatus {
        case .ordered:
            .readyForDelivery
        case .readyForDelivery:
            Status.delivered
        case .delivered:
            currentStatus
        }
    }
    
    private func makeMessageData(with orderID: UUID, newStatus: Status) throws(ExecutionError) -> Data {
        let updatedOrder = Order.Update(id: orderID, status: newStatus)
        let message = WebSocketMessage(data: Send.update(updatedOrder))
        return try encode(message)
    }
    
    private func encode(_ message: WebSocketMessage<Send>) throws(ExecutionError) -> Data {
        do {
            return try JSONEncoder().encode(message)
        } catch {
            throw .encodeFailure
        }
    }
}
#endif
