//
//  DHPublicKey.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/19/25.
//

import struct Foundation.Data

struct DHPublicKey: Codable {
    let id: String
    let publicKey: Data
}
