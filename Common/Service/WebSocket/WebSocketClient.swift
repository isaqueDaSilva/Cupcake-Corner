//
//  WebSocketClient.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/22/25.
//

import Combine
import Foundation
import Network

/// Default executor for ``WebSocketClient``.
@globalActor final actor WebSocketActor {
    static let shared = WebSocketActor()
    
    private init() { }
}

/// The main representation of the WebSocket client.
@WebSocketActor
final class WebSocketClient: NSObject, Sendable {
    private typealias Message = URLSessionWebSocketTask.Message
    
    /// Default logger of the WS client.
    private let logger = AppLogger(category: "WebSocketClient")
    
    /// Default session that the WebSocket will be created from.
    private let session: URLSession
    
    /// Deafult configuration of the client.
    private let configuration: WebSocketConfiguration
    
    /// Default instance of the network monitor.
    private var monitor: NWPathMonitor?
    
    /// The default representation of the ws channel.
    private var wsTask: URLSessionWebSocketTask?
    
    /// The default ping executor.
    private var pingTask: Task<Void, Never>?
    
    /// A counter that stores the current number of times that we try to send a ping.
    private var pingTryCount = 0
    
    /// A default combine subject that transimit all messages to a top level application.
    var onReceiveMessageSubject: PassthroughSubject<WebSocketMessage<Receive>, AppAlert> = .init()
    
    /// A default combine subject that transimit the current state of the connection status.
    var connectionStateSubject: CurrentValueSubject<ConnectionState, Never> = .init(.disconnected)
    
    /// A representation of the current connection sttae
    private var connectionState: ConnectionState = .disconnected {
        didSet {
            self.connectionStateSubject.send(connectionState)
        }
    }
    
    /// Establishes a connection in a ws channel.
    func connect() {
        guard wsTask == nil else {
            self.logger.info("WebSocket Task is already exists")
            return
        }
        
        self.wsTask = self.configuration.networkHandler.getWebSocketTask(with: self.session)
        self.wsTask?.delegate = self
        self.wsTask?.resume()
        
        self.logger.info("Starting the channel connection")
        
        self.connectionState = .connecting
        self.receiveMessage()
        self.startMonitorNetworkConnectivity()
        self.schedulePing()
    }
    
    /// Send an ``WebSocketClientMessage`` to the channel.
    func send(_ message: SendMessage) async throws(AppAlert) {
        guard let task = wsTask, connectionState == .connected else {
            self.logger.error(
                "Cannot possible to send a message. WS Task: \(self.wsTask == nil ? "On" : "Off"); Connection State: \(self.connectionState.rawValue)"
            )
            throw .noConnection
        }
        
        let messageData = try EncoderAndDecoder.encodeData(message)
        
        do {
            try await task.send(.data(messageData))
            self.logger.info("Message sent with success.")
        } catch {
            self.logger.error("Failed to send message. Error: \(error.localizedDescription)")
            
            throw .failedToSendData
        }
    }
    
    /// Removes a connection from the channel and the cancels the network monitor execution.
    func disconnect() {
        self.disconnect(shouldRemoveNetworkMonitor: true)
    }
    
    /// Removes a connection from the channel.
    /// - Parameter shouldRemoveNetworkMonitor: Defines if you wants to disconnect only the ws channel
    /// or you wants to stop the network monitor as well.
    private func disconnect(shouldRemoveNetworkMonitor: Bool) {
        self.wsTask?.cancel()
        self.wsTask = nil
        self.pingTask?.cancel()
        self.pingTask = nil
        self.connectionState = .disconnected
        if shouldRemoveNetworkMonitor {
            self.monitor?.cancel()
            self.monitor = nil
        }
        
        self.logger.info("Channel was diconnected with success.")
    }
    
    /// Performs the reconnection from the channel.
    private func reconnect() {
        self.logger.info("Starting reconnection...")
        self.disconnect(shouldRemoveNetworkMonitor: false)
        self.connect()
    }
    
    /// Handles with the incoming messages.
    private func receiveMessage() {
        self.wsTask?.receive { result in
            Task { @WebSocketActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let wsMessage):
                    try await self.lookMessage(wsMessage)
                    self.logger.info("Message transmited with success.")
                case .failure(let failure):
                    self.onReceiveMessageSubject.send(completion: .failure(.unknownError(error: failure)))
                    self.logger.error("Error when we receive a message. Error: \(failure.localizedDescription)")
                }
                
                if self.connectionState == .connected {
                    self.receiveMessage()
                }
            }
        }
    }
    
    /// Gets and decode a message that comes from the web socket channel, and streams to the application.
    /// - Parameter message: The enum ``Message`` that comes from the WS channel with a binary or text message representation.
    private func lookMessage(_ message: Message) async throws {
        switch message {
        case .data(let messageData):
            let message = try EncoderAndDecoder.decodeResponse(type: ReceiveMessage.self, by: messageData)
            self.onReceiveMessageSubject.send(message)
        case .string(_):
            self.onReceiveMessageSubject.send(completion: .failure(.dataNotSuported))
        @unknown default:
            fatalError()
        }
    }
    
    /// Starts the network monitor.
    private func startMonitorNetworkConnectivity() {
        guard self.monitor == nil else { return }
        self.monitor = .init()
        self.monitor?.pathUpdateHandler = { path in
            Task { @WebSocketActor [weak self] in
                guard let self else { return }
                if path.status == .satisfied, self.wsTask == nil {
                    self.connect()
                    return
                }
                
                if path.status != .satisfied {
                    self.disconnect(shouldRemoveNetworkMonitor: false)
                }
            }
        }
        self.monitor?.start(queue: .main)
    }
    
    /// Schedule when the ping will be sent to the server.
    private func schedulePing() {
        self.pingTask?.cancel()
        self.pingTryCount = 0
        self.pingTask = Task { [weak self] in
            while true {
                try? await Task.sleep(for: .seconds(self?.configuration.pingInterval ?? 5))
                guard !Task.isCancelled, let self, let task = self.wsTask else { break }
                
                if task.state == .running, self.pingTryCount < self.configuration.pingTryToReconnectCountLimit {
                    self.pingTryCount += 1
                    self.logger.info("Ping: Send")
                    task.sendPing { error in
                        if let error {
                            self.logger.error("Ping Failed: \(error.localizedDescription)")
                        } else {
                            self.logger.info("Ping: Pong Received")
                            Task { @WebSocketActor [weak self] in
                                self?.pingTryCount = 0
                            }
                        }
                    }
                } else {
                    self.reconnect()
                    break
                }
            }
        }
    }
    
    /// Creates a new instance of the ``WebSocketClient``.
    /// - Parameters:
    ///   - configuration: The default configuration of the channel.
    ///   - session: The default URLSession instance that the WebSocket channel will be created,
    nonisolated init(configuration: WebSocketConfiguration, session: URLSession = .init(configuration: .default)) {
        self.configuration = configuration
        self.session = session
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        Task { @WebSocketActor [weak self] in
            guard let self else { return }
            
            self.connectionState = .connected
            
            self.logger.info("Connected on the channel.")
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        Task { @WebSocketActor [weak self] in
            guard let self else { return }
            
            self.connectionState = .disconnected
            
            self.logger.info("Disconnected from the channel. Close code: \(closeCode.rawValue)")
        }
    }
    
}

extension WebSocketClient {
    /// Representation of the current state of a WebSocket channel.
    public enum ConnectionState: String, Sendable {
        case disconnected = "Disconnected"
        case connecting = "Connecting"
        case connected = "Connected"
    }
}
