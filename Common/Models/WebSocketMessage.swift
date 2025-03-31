//
//  WebSocketMessage.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import Foundation

struct WebSocketMessage: Decodable, Sendable {
    let data: Receive
}

enum Receive: Decodable, Sendable {
    case newOrder(Order)
    case get(Order.ReadList)
    case update(Order)
    case delivered(UUID)
}
