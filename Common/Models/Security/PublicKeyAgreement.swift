//
//  PublicKeyAgreement.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/19/25.
//

import Foundation

struct PublicKeyAgreement: Codable {
    let id: UUID
    let publicKey: Data
}
