//
//  Action.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

enum Action {
    case create(Cupcake)
    case update(Cupcake)
    case delete(UUID)
}
