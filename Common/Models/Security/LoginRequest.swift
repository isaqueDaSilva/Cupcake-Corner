//
//  LoginRequest.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/20/25.
//

struct LoginRequest: Codable {
    let clientPublicKey: DHPublicKey
    let email: String
    let password: EncryptedField
}
