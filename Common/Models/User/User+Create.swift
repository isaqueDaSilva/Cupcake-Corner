//
//  User+Create.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import CryptoKit
import ErrorWrapper
import Foundation

extension User {
    /// A representation of the data that used for create an user.
    struct Create: Encodable, Sendable {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
        
        var clientPublicKey: PublicKeyAgreement? = nil
        var encryptedPassword: Data? = nil
        
        enum CodingKeys: CodingKey {
            case name
            case email
            case password
            case clientPublicKey
        }
        
        func encode(to encoder: any Encoder) throws(ExecutionError) {
            guard let encryptedPassword, let clientPublicKey else { throw .missingData }
            
            do {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.name, forKey: .name)
                try container.encode(self.email, forKey: .email)
                try container.encode(encryptedPassword, forKey: .password)
                try container.encode(clientPublicKey, forKey: .clientPublicKey)
            } catch {
                throw .encodeFailure
            }
        }
        
        init() {
            self.name = ""
            self.email = ""
            self.password = ""
            self.confirmPassword = ""
        }
    }
}

extension User.Create {
    private func checkPassword() throws(ExecutionError) {
        guard password == confirmPassword else {
            throw .init(
                title: "Field don't match",
                descrition: "The password and confirm password needs to be the same."
            )
        }
    }
    
    mutating func encryptCredentials(with clientPublicKey: PublicKeyAgreement, sharedKey: SymmetricKey) throws(ExecutionError) {
        try checkPassword()
        
        self.clientPublicKey = clientPublicKey
        
        guard let password = self.password.data(using: .utf8)
        else {
            throw .missingData
        }
        
        self.encryptedPassword = try Encryptor.encrypt(password, with: sharedKey)
    }
}
