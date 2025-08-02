//
//  Token.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import struct Foundation.Date

struct Token: Codable, Sendable, Equatable {
    let token: String
    let expirationTime: Date
}
