//
//  SecureServerComunication.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/19/25.
//

import CryptoKit
import Foundation

typealias SymmetricKey = CryptoKit.SymmetricKey
typealias PrivateKey = P384.KeyAgreement.PrivateKey
typealias PublicKey = P384.KeyAgreement.PublicKey

enum SecureServerComunication {
    static func getPublicAndSharedKey(with session: URLSession) async throws -> (UUID, PublicKey, SymmetricKey) {
        let privateKey = PrivateKey()
        
        let serverPublicKey = try await Self.getServerPublicKey(with: session)
        
        let serverPublicKeyRawRespresentation = try PublicKey(rawRepresentation: serverPublicKey.publicKey)
        let sharedKey = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKeyRawRespresentation)
        
        let symmetricSharedKey = sharedKey.x963DerivedSymmetricKey(
            using: SHA512.self,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        return (serverPublicKey.privateKeyID, privateKey.publicKey, symmetricSharedKey)
    }
    
    private static func getServerPublicKey(with session: URLSession) async throws -> ECKeyPair {
        let request = Network(
            method: .get,
            scheme: .https,
            path: "/serverPublicKey",
            fields: [:],
            requestType: .get
        )
        
        let (data, response) = try await request.getResponse(with: session)
        
        guard response.status == .ok else { throw AppAlert.badResponse }
        
        return try EncoderAndDecoder.decodeResponse(type: ECKeyPair.self, by: data)
    }
}
