//
//  WebSocketMessage.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import Foundation

struct WebSocketMessage<T: Codable & Sendable>: Codable, Sendable {
    let data: T
}

#if ADMIN
enum Send: Codable, Sendable {
    case update(Order.Update)
}
#endif

enum Receive: Codable, Sendable {
    case newOrder(Order)
    case update(Order)
}
