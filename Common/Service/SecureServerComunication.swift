//
//  SecureServerComunication.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/19/25.
//

import CryptoKit
import ErrorWrapper
import Foundation
import NetworkHandler

typealias PrivateKey = P384.KeyAgreement.PrivateKey
typealias PublicKey = P384.KeyAgreement.PublicKey

enum SecureServerComunication {
    static func getPublicAndSharedKey(with session: URLSession) async throws(ExecutionError) -> (UUID, PublicKey, SymmetricKey) {
        let privateKey = PrivateKey()
        
        let serverPublicKey = try await getServerPublicKey(with: session)
        
        do {
            let serverPublicKeyRawRespresentation = try PublicKey(rawRepresentation: serverPublicKey.publicKey)
            let sharedKey = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKeyRawRespresentation)
            
            let symmetricSharedKey = sharedKey.x963DerivedSymmetricKey(
                using: SHA512.self,
                sharedInfo: Data(),
                outputByteCount: 32
            )
            
            return (serverPublicKey.id, privateKey.publicKey, symmetricSharedKey)
        } catch {
            throw .internalError
        }
    }
    
    private static func getServerPublicKey(with session: URLSession) async throws(ExecutionError) -> PublicKeyAgreement {
        let (data, response) = try await Network.getData(
            path: EndpointBuilder.makePath(endpoint: .serverPublicKey, path: nil),
            httpMethod: .get,
            session: session
        )
        try Network.checkResponse(response)
        let serverPublicKey = try Network.decodeResponse(type: PublicKeyAgreement.self, by: data)
        
        return serverPublicKey
    }
}
