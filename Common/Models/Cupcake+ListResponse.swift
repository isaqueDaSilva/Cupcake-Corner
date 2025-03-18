//
//  Cupcake+ListResponse.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/17/25.
//

import Foundation

extension Cupcake {
    struct ListResponse: Codable {
        let cupcakes: [UUID: Cupcake]
    }
}
