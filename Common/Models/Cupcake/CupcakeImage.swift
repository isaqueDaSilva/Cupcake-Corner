//
//  CupcakeImage.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/21/25.
//

import Foundation

struct CupcakeImage: Codable, Sendable {
    var imageData: Data
}

extension CupcakeImage: Equatable {
    static func == (lhs: CupcakeImage, rhs: CupcakeImage) -> Bool {
        lhs.imageData == rhs.imageData
    }
}

extension CupcakeImage {
    func sendImage(
        with cupcakeID: String,
        token: String,
        session: URLSession
    ) async throws -> Response {
        let cupcakeImageData = try EncoderAndDecoder.encodeData(self)
        
        let request = _Network(
            method: .put,
            scheme: .https,
            path: "/cupcake/update/\(cupcakeID)",
            fields: [.authorization : token],
            requestType: .upload(cupcakeImageData)
        )
        
        let (_, response) = try await request.getResponse(with: session)
        
        return response
    }
    
    static func getImage(
        with cupcakeID: String,
        token: String,
        session: URLSession
    ) async throws -> (Data, Response) {
        let request = _Network(
            method: .get,
            scheme: .https,
            path: "/cupcake/image/\(cupcakeID)",
            fields: [
                .authorization : token,
                .contentType : _Network.HeaderValue.json.rawValue
            ],
            requestType: .get
        )
        
        return try await request.getResponse(with: session)
    }
}
