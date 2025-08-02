//
//  ECKeyPair.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/29/25.
//

import Foundation

struct ECKeyPair: Codable {
    let privateKeyID: UUID
    let publicKey: Data
    
    /// Do not utilize this initializer directly, because it's creates a random id and an empty public key data.
    init() {
        self.privateKeyID = .init()
        self.publicKey = .init()
    }
    
    init(privateKeyID: UUID, publicKey: Data) {
        self.privateKeyID = privateKeyID
        self.publicKey = publicKey
    }
}
