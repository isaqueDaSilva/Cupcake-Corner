//
//  Action.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

enum Action {
    case noAction
    case create(ReadCupcake)
    case update(ReadCupcake)
    case delete
}
