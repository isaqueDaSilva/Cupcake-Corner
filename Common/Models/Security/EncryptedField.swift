//
//  EncryptedField.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/20/25.
//

import struct Foundation.Data

struct EncryptedField: Codable {
    let cipher: Data
    let nonce: Data
    let tag: Data
}
