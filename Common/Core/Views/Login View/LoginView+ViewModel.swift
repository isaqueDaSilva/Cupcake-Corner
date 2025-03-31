//
//  LoginView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import CryptoKit
import ErrorWrapper
import Foundation
import KeychainService
import NetworkHandler
import Observation

extension LoginView {
    @Observable
    @MainActor
    final class ViewModel {
        var email = ""
        var password = ""
        
        var isLoading = false
        var error: ExecutionError?
        
        func performLogin(
            with session: URLSession = .shared,
            completation: @escaping (User.Get) throws -> Void
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let (serverPublicKeyID, publicKey, sharedKey) = try await SecureServerComunication.getPublicAndSharedKey(
                        with: session
                    )
                    
                    let (loginData, clientPublicKey) = try self.makeCredentials(
                        with: serverPublicKeyID,
                        publicKey: publicKey,
                        sharedKey: sharedKey
                    )
                    
                    let encodedPublicKey = try Network.encodeData(clientPublicKey)
                    
                    let (data, response) = try await self.makeLogin(
                        publicKey: encodedPublicKey,
                        loginCreadentials: loginData,
                        session: session
                    )
                    
                    try self.checkResponse(response)
                    
                    let loginResponse = try Network.decodeResponse(type: LoginResponse.self, by: data)
                    
                    try self.storeToken(loginResponse.jwtToken)
                    
                    try await MainActor.run { [weak self] in
                        guard self != nil else { return }
                        
                        try completation(loginResponse.userProfile)
                    }
                } catch let error as ExecutionError {
                    await self.setError(error)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                }
            }
        }
        
        private func makeCredentials(
            with serverPublicKeyID: UUID,
            publicKey: PublicKey,
            sharedKey: SymmetricKey
        ) throws(ExecutionError) -> (String, PublicKeyAgreement) {
            guard !email.isEmpty,!password.isEmpty,
                  let passwordData = self.password.data(using: .utf8)
            else {
                throw .missingData
            }
            
            let encryptedPassword = try Encryptor.encrypt(passwordData, with: sharedKey).base64EncodedString()
            
            let loginData = ("\(email):\(encryptedPassword)".data(using: .utf8))?.base64EncodedString()
            
            guard let loginData else { throw .missingData }
            
            let clientPublicKey = PublicKeyAgreement(id: serverPublicKeyID, publicKey: publicKey.rawRepresentation)
            
            return (loginData, clientPublicKey)
        }
        
        private func makeLogin(
            publicKey: Data,
            loginCreadentials: String,
            session: URLSession
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let loginValue = "\(EndpointBuilder.Header.basic.rawValue) \(loginCreadentials)"
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .auth, path: .login),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.contentType.rawValue: EndpointBuilder.HeaderValue.json.rawValue,
                    EndpointBuilder.Header.authorization.rawValue: loginValue
                ],
                body: publicKey,
                session: session
            )
        }
        
        private func checkResponse(_ response: URLResponse) throws(ExecutionError) {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard let statusCode, statusCode == 200 else {
                if let statusCode, statusCode == 401 {
                    throw .accessDenied
                } else {
                    throw .resposeFailed
                }
            }
        }
        
        private func storeToken(_ token: Token) throws(ExecutionError) {
            do {
                _ = try KeychainService.store(for: token)
            } catch {
                throw .internalError
            }
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
    }
}
