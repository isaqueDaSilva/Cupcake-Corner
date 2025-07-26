//
//  Action.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import struct Foundation.UUID

enum Action {
    case noAction
    case update(ReadCupcake)
    case delete(UUID)
}
