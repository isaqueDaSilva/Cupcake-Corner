//
//  TokenPair.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/29/25.
//

import struct Foundation.Data

struct TokenPair: Codable, Sendable {
    let accessToken: Token
    let refreshToken: Token
    let publicKey: Data
}
