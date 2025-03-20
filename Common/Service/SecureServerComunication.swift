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

final actor SecureServerComunication {
    static let shared = SecureServerComunication()
    
    private var serverPublicKey: DHPublicKey?
    
    func getKey(with session: URLSession = .shared) async throws(ExecutionError) {
        guard serverPublicKey == nil else { return }
        
        try await getServerPublicKey(with: session)
    }
    
    func getPublicAndSharedKey() throws(ExecutionError) -> (String, PublicKey, SymmetricKey) {
        let privateKey = PrivateKey()
        
        guard let serverPublicKey else {
            throw .missingData
        }
        
        do {
            let serverPublicKeyRawRespresentation = try PublicKey(rawRepresentation: serverPublicKey.publicKey)
            let sharedKey = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKeyRawRespresentation)
            
            let symmetricSharedKey = sharedKey.x963DerivedSymmetricKey(
                using: SHA512.self,
                sharedInfo: Data(),
                outputByteCount: 64
            )
            
            return (serverPublicKey.id, privateKey.publicKey, symmetricSharedKey)
        } catch {
            throw .internalError
        }
    }
    
    func emptyServerPublicKey() {
        self.serverPublicKey = nil
    }
    
    private func getServerPublicKey(with session: URLSession) async throws(ExecutionError) {
        let (data, response) = try await getData(with: session)
        try checkResponse(response)
        let serverPublicKey = try decode(data)
        
        self.serverPublicKey = serverPublicKey
    }
    
    private func getData(with session: URLSession) async throws(ExecutionError) -> (Data, URLResponse) {
        let endpoint = Endpoint(
            scheme: EndpointBuilder.httpSchema,
            host: EndpointBuilder.domainName,
            path: EndpointBuilder.makePath(endpoint: .api, path: .serverPublicKey),
            httpMethod: .post
        )
        
        let handler = NetworkHandler<ExecutionError>(
            endpoint: endpoint,
            session: session,
            unkwnonURLRequestError: .internalError,
            failureToGetDataError: .failedToGetData
        )
        
        return try await handler.getResponse()
    }
    
    private func checkResponse(_ response: URLResponse) throws(ExecutionError) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard let statusCode, statusCode == 200 else {
            throw .resposeFailed
        }
    }
    
    private func decode(_ serverPublicKeyData: Data) throws(ExecutionError) -> DHPublicKey {
        do {
            return try JSONDecoder().decode(DHPublicKey.self, from: serverPublicKeyData)
        } catch {
            throw .decodedFailure
        }
    }
    
    
    private init() { }
}
