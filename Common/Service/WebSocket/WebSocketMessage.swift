//
//  WebSocketMessage.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/22/25.
//

import Foundation

typealias ReceiveMessage = WebSocketMessage<Receive>
typealias SendMessage = WebSocketMessage<Send>

struct WebSocketMessage<T: Codable>: Codable {
    let data: T
}

enum Receive: Codable, Sendable {
    case newOrder(Order)
    case get(Page<Order>)
    case update(Order)
}

enum Send: Codable, Sendable {
    case queryRecords(Int)
    case update(UUID, Status)
}
