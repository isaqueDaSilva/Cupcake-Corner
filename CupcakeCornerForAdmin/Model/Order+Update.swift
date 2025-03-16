//
//  Order+Update.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import Foundation

extension Order {
    /// A representation of the data that used for update an order..
    struct Update: Codable, Sendable {
        var id: UUID
        var status: Status
    }
}
