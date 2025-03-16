//
//  User+Create.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import ErrorWrapper
import Foundation

extension User {
    /// A representation of the data that used for create an user.
    struct Create: Encodable, Sendable {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
        
        enum CodingKeys: CodingKey {
            case name
            case email
            case password
        }
        
        func encode(to encoder: any Encoder) throws(ExecutionError) {
            guard password == confirmPassword else {
                throw .init(
                    title: "Field don't match",
                    descrition: "The password and confirm password needs to be the same."
                )
            }
            
            do {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.name, forKey: .name)
                try container.encode(self.email, forKey: .email)
                try container.encode(self.password, forKey: .password)
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
