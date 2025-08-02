//
//  TokenFields.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/29/25.
//

import Foundation

struct TokenFields: Codable {
    let accessToken: String
    let refreshToken: String
    let publicKeyForEncryption: Data
}

extension TokenFields {
    func refreshToken(with session: URLSession) async throws -> (Data, Response){
        let tokenFieldsData = try EncoderAndDecoder.encodeData(self)
        
        return try await Network(
            method: .put,
            scheme: .https,
            path: "/auth/refresh-token",
            fields: [
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .upload(tokenFieldsData)
        ).getResponse(with: session)
    }
}
