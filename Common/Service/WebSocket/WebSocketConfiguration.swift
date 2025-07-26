//
//  WebSocketConfiguration.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/22/25.
//

import struct Foundation.TimeInterval

/// A representation data that enables the configuration process for ``WebSocketClient`` type.
public struct WebSocketConfiguration: Sendable {
    let networkHandler: Network
    let pingInterval: TimeInterval
    let pingTryToReconnectCountLimit: Int
    
    init(
        networkHandler: Network,
        pingInterval: TimeInterval = 20,
        pingTryToReconnectCountLimit: Int = 3
    ) {
        self.networkHandler = networkHandler
        self.pingInterval = pingInterval
        self.pingTryToReconnectCountLimit = pingTryToReconnectCountLimit
    }
}
