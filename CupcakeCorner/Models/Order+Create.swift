//
//  Order+Create.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

extension Order {
    struct Create: Encodable, Sendable {
        let cupcakeID: UUID
        let quantity: Int
        let extraFrosting: Bool
        let addSprinkles: Bool
        let finalPrice: Double
        let paymentMethod: PaymentMethod
    }
}
