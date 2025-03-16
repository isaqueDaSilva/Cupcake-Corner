//
//  Cupcake+Create.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

extension Cupcake {
    /// A representation of the data that used for create a cupcake.
    struct Create: Encodable, Sendable {
        var flavor: String
        var coverImage: Data
        var ingredients: [String]
        var price: Double
    }
}
