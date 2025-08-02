//
//  KeyCollection.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/29/25.
//

import struct Foundation.Data

struct KeyCollection: Codable {
    let keyPairForDecryption: ECKeyPair
    let publicKeyForEncryption: Data
    
    /// Do not utilize this initializer directly, because it's creates a empty keyPairForDecryption and an empty public key for encryption data.
    init() {
        self.keyPairForDecryption = .init()
        self.publicKeyForEncryption = .init()
    }
    
    init(keyPairForDecryption: ECKeyPair, publicKeyForEncryption: Data) {
        self.keyPairForDecryption = keyPairForDecryption
        self.publicKeyForEncryption = publicKeyForEncryption
    }
}
