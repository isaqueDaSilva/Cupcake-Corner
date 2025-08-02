//
//  OrderView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import OrderedCollections
import Foundation

// MARK: COMMON
extension OrderView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "BagView+ViewModel")
        
        @ObservationIgnored
        private var wsService: WebSocketClient?
        
        @ObservationIgnored
        private var channelObserverTask: Task<Void, Never>?
        
        @ObservationIgnored
        private var connectionStatusTask: Task<Void, Never>?
        
        @ObservationIgnored
        private var waitingForDisconnectFromChannelTask: Task<Void, Never>?
        
        private var orderedOrders: OrderedDictionary<UUID, Order> = [:] {
            didSet {
                self.logger.info("The ordered orders list was updated for \(self.orderedOrders.count) elements.")
            }
        }
        
        private var readyToDeliveryOrders: OrderedDictionary<UUID, Order> = [:] {
            didSet {
                self.logger.info(
                    "The ready to delivery orders list was updated for \(self.readyToDeliveryOrders.count) elements."
                )
            }
        }
        
        private var pageMetadata: PageMetadata = .init() {
            didSet {
                self.logger.info("The page metadata was update for \(self.pageMetadata.description)")
            }
        }
        
        var viewState: ViewState = .default {
            didSet {
                self.logger.info("View state update for \(self.viewState) status.")
            }
        }
        
        var error: AppAlert? {
            didSet {
                if let error {
                    self.logger.info("An error was thrown. Error Description: \(error.description).")
                }
            }
        }
        
        var statusType: Status = .ordered {
            didSet {
                self.logger.info("The current status view type was changed for \(self.statusType).")
            }
        }
        
        var connectionStatus: WebSocketClient.ConnectionState = .disconnected {
            didSet {
                self.logger.info("A new connection was setted with success. Status: \(self.connectionStatus)")
            }
        }
        
        var orderIndices: Range<Int> {
            self.orders.indices
        }
        
        var isLoading: Bool {
            self.viewState == .loading ||
            self.viewState == .fetchingMore ||
            self.viewState == .refreshing
        }
        
        var orders: [Order] {
            return switch statusType {
            case .ordered:
                self.orderedOrders.values.elements
            case .readyForDelivery:
                self.readyToDeliveryOrders.values.elements
            case .delivered:
                []
            }
        }
        
        init() {
            self.connect()
        }
    }
}

// MARK: - Connect in channel -
extension OrderView.ViewModel {
    func connect(with session: URLSession = .shared) {
        self.viewState = .loading
        
        self.setWSService(with: session)
        
        Task { [weak self] in
            guard let self else { return }
            
            #if DEBUG
            await self.setup()
            #else
            guard let wsService else {
                self.logger.error("The are no ws service to handle with the connection.")
                return await setError(.noConnection)
            }
            
            await wsService.connect()
            
            logger.info("The connection was established with success.")
            
            self.observerConnectionState()
            self.observerChangesInChannel()
            #endif
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.viewState = .default
            }
        }
    }
    
    func reconnect() {
        guard self.wsService == nil else {
            self.removeDisconnectionRequest()
            return
        }

        self.removeDisconnectionRequest()
        self.connect()
    }
    
    private func setWSService(with session: URLSession) {
        do {
            let token = try TokenHandler.getValue(key: .accessToken)
            self.configureService(with: token, session: session)
        } catch {
            Task { [weak self] in
                guard let self else { return }
                
                await setError(.init(title: "Failed to connect to channel", description: error.localizedDescription))
            }
        }
    }
    
    private func configureService(with token: String, session: URLSession) {
        let networkHandler = Network(
            method: .get,
            scheme: .wss,
            path: "/channel",
            fields: [
                .authorization : token,
                .contentType : Network.HeaderValue.vdnAPIJSON.rawValue
            ]
        )
        
        let wsConfigurantion = WebSocketConfiguration(networkHandler: networkHandler)
        
        let wsService = WebSocketClient(
            configuration: wsConfigurantion,
            session: session
        )
        
        self.wsService = wsService
        
        self.logger.info("WSService was setted with success.")
    }
}

// MARK: - Disconnect from channel -
extension OrderView.ViewModel {
    func disconnect(isWaitingForDisconnect: Bool) {
        self.waitingForDisconnectFromChannelTask = Task { [weak self] in
            guard let self else { return }
            
            await self.scheduleChannelDisconnection(isWaitingForDisconnect)
        }
    }
    
    private func removeDisconnectionRequest() {
        guard waitingForDisconnectFromChannelTask != nil else { return }
        
        self.waitingForDisconnectFromChannelTask?.cancel()
        self.waitingForDisconnectFromChannelTask = nil
        self.logger.info("Disconnection channel request was removed with success.")
    }
    
    private func scheduleChannelDisconnection(_ isWaitingForDisconnect: Bool) async {
        if isWaitingForDisconnect {
            self.logger.info("Awaiting for complete the 300s to end the channel.")
            try? await Task.sleep(for: .seconds(300))
        }
        
        guard self.waitingForDisconnectFromChannelTask != nil else { return }
        
        self.logger.info("Starting end the channel.")
        await self.wsService?.disconnect()
        self.wsService = nil
        self.channelObserverTask?.cancel()
        self.channelObserverTask = nil
        
        self.waitingForDisconnectFromChannelTask?.cancel()
        self.waitingForDisconnectFromChannelTask = nil
        
        self.logger.info("The channel's connection was removed with success.")
    }
}

// MARK: - Channel Messages Observation -
extension OrderView.ViewModel {
    private func observerChangesInChannel() {
        channelObserverTask?.cancel()
        
        guard let wsService else { return }
        
        channelObserverTask = Task { @WebSocketActor [weak self] in
            guard let self else { return }
            
            do {
                for try await message in wsService.onReceiveMessageSubject.values {
                    await self.handlesWithReceivedMessage(message)
                }
                
                await disconnect(isWaitingForDisconnect: false)
            } catch {
                await self.setError(
                    .init(
                        title: "Failed to receive message",
                        description: error.localizedDescription
                    )
                )
            }
        }
    }
    
    private func handlesWithReceivedMessage(_ message: ReceiveMessage) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            switch message.data {
            case .newOrder(let newOrder):
                self.addNewOrder(newOrder)
            case .get(let pageList):
                self.fillOrderList(pageList)
            case .update(let updatedOrder):
                self.updateAnOrder(updatedOrder)
            }
            
        }
    }
    
    private func addNewOrder(_ newOrder: Order) {
        self.orderedOrders.updateValue(newOrder, forKey: newOrder.id)
        self.logger.info("A new order was added with success in the list.")
    }
    
    private func fillOrderList(_ listResult: Page<Order>) {
        for order in listResult.items {
            switch order.status {
            case .ordered:
                self.orderedOrders.updateValue(order, forKey: order.id)
            case .readyForDelivery:
                self.readyToDeliveryOrders.updateValue(order, forKey: order.id)
            case .delivered:
                break
            }
        }
        
        self.pageMetadata = listResult.metadata
        
        let totalOfItems = self.orderedOrders.count + self.readyToDeliveryOrders.count
        
        self.viewState = self.pageMetadata.total == totalOfItems ? .loadedAll : .default
        
        self.logger.info("The list was setted with success.")
    }
    
    private func updateAnOrder(_ updatedOrder: Order) {
        switch updatedOrder.status {
        case .ordered:
            break
        case .readyForDelivery:
            self.orderedOrders.removeValue(forKey: updatedOrder.id)
            self.readyToDeliveryOrders.updateValue(updatedOrder, forKey: updatedOrder.id)
        case .delivered:
            self.readyToDeliveryOrders.removeValue(forKey: updatedOrder.id)
        }
        
        self.logger.info("An order was updated with success.")
    }
}

// MARK: - Channel connection observation -
extension OrderView.ViewModel {
    private func observerConnectionState() {
        self.connectionStatusTask?.cancel()
        
        guard let wsService else { return }
        
        self.connectionStatusTask = Task { @WebSocketActor [weak self] in
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
extension OrderView.ViewModel {
    private func setError(_ error: AppAlert) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.error = .init(
                title: "Failed to receive message",
                description: error.localizedDescription
            )
        }
    }
}

// MARK: -- Message in Channel --

// MARK: Common

extension OrderView.ViewModel {
    func fetchMorePages(isVisible: Bool, index: Int) {
        guard self.viewState == .default && self.isValidToFetchMore(isVisible: isVisible, index: index) else { return }
        
        self.viewState = .fetchingMore
        
        Task { [weak self] in
            guard let self, let wsService else { return }
            
            do {
                try await Order.requestMorePages(
                    currentPage: self.pageMetadata.page,
                    with: wsService
                )
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.error = .init(
                        title: "Failed to get more orders.",
                        description: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func isValidToFetchMore(isVisible: Bool, index: Int) -> Bool {
        let eightyPorcentIndex = Int((Double((self.orders.count - 1)) * 0.8).rounded(.up))
        
        guard isVisible, self.orders.indices.contains(eightyPorcentIndex),
              self.orders[index].id == self.orders[eightyPorcentIndex].id else {
            return false
        }
        
        return true
    }
}

#if ADMIN
extension OrderView.ViewModel {
    func updateOrder(at index: Int, session: URLSession = .shared) {
        guard let wsService else { return }
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.orders[index].update(with: wsService)
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.error = .init(
                        title: "Failed to update order.",
                        description: error.localizedDescription
                    )
                }
            }
        }
    }
}
#endif

// MARK: - DEBUG Setup -
#if DEBUG
extension OrderView.ViewModel {
    func setup() async {
        try? await Task.sleep(for: .seconds(4))
        
        await MainActor.run {
            for orderList in Order.mocksDict {
                switch orderList.key {
                case .ordered:
                    self.orderedOrders = orderList.value
                case .readyForDelivery:
                    self.readyToDeliveryOrders = orderList.value
                case .delivered:
                    break
                }
            }
            
            self.connectionStatus = .connected
        }
    }
}
#endif
