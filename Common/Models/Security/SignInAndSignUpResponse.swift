//
//  LoginResponse.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import Foundation

typealias SignUpResponse = SignInAndSignUpResponse
typealias SignInResponse = SignInAndSignUpResponse

struct SignInAndSignUpResponse: Codable {
    let tokens: TokenPair
    let profile: Profile
}

extension SignInAndSignUpResponse {
    static func signIn(with loginValue: String, keyCollectionData: Data, session: URLSession) async throws -> Self {
        let (data, response) = try await Network(
            method: .post,
            scheme: .https,
            path: "/auth/signin",
            fields: [
                .contentType : Network.HeaderValue.json.rawValue,
                .authorization : loginValue
            ],
            requestType: .upload(keyCollectionData)
        ).getResponse(with: session)
        
        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw AppAlert.accessDenied
            } else {
                throw AppAlert.badResponse
            }
        }
        
        return try EncoderAndDecoder.decodeResponse(type: SignInResponse.self, by: data)
    }
    
    static func signUp(
        with name: String,
        email: String,
        encryptedPassword: Data,
        keyCollection: KeyCollection,
        and session: URLSession
    ) async throws -> Self {
        let (data, response) = try await UserDTO(
            name: name,
            email: email,
            password: encryptedPassword,
            keyCollection: keyCollection
        ).createAccount(with: session)
        
        guard response.status == .ok else {
            throw AppAlert.badResponse
        }
        
        return try EncoderAndDecoder.decodeResponse(type: SignUpResponse.self, by: data)
    }
}
