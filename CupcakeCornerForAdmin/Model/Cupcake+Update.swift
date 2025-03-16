//
//  Cupcake+Update.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import Foundation

extension Cupcake {
    struct Update: Encodable, Identifiable {
        let id: UUID
        let flavor: String?
        let coverImage: Data?
        let ingredients: [String]?
        let price: Double?
    }
}
