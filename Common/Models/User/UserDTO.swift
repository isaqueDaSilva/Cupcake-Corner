//
//  User+Create.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import CryptoKit
import Foundation

typealias CreateUser = UserDTO
typealias Profile = UserDTO

struct UserDTO {
    let id: UUID
    let name: String
    let email: String
    let password: Data
    let keyCollection: KeyCollection
    
    init(name: String, email: String, password: Data, keyCollection: KeyCollection) {
        self.id = .init()
        self.name = name
        self.email = email
        self.password = password
        self.keyCollection = keyCollection
    }
}

extension UserDTO: Codable {
    enum Key: CodingKey {
        case id
        case name
        case email
        case password
        case keyCollection
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.password, forKey: .password)
        try container.encode(self.keyCollection, forKey: .keyCollection)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.password = .init()
        self.keyCollection = .init()
    }
}

extension UserDTO {
    func createAccount(with session: URLSession) async throws -> (Data, Response) {
        let newUserData = try EncoderAndDecoder.encodeData(self)
        
        let request = Network(
            method: .post,
            scheme: .https,
            path: "/auth/signup",
            fields: [.contentType : Network.HeaderValue.json.rawValue],
            requestType: .upload(newUserData)
        )
        
        return try await request.getResponse(with: session)
    }
}
