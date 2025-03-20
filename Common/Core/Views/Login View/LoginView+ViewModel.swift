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
            
            Task {
                do {
                    let credentials = try await makeCredentials()
                    
                    let encodedCredentials = try encode(credentials)
                    
                    let (data, response) = try await makeLogin(
                        loginRequestData: encodedCredentials,
                        session: session
                    )
                    
                    try checkResponse(response)
                    
                    let loginResponse = try decode(data)
                    
                    try storeToken(loginResponse.jwtToken)
                    
                    try await MainActor.run {
                        try completation(loginResponse.userProfile)
                    }
                } catch let error as ExecutionError {
                    await self.setError(error)
                }
                
                await SecureServerComunication.shared.emptyServerPublicKey()
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func makeCredentials() async throws(ExecutionError) -> LoginRequest {
            guard !email.isEmpty, let emailData = self.email.data(using: .utf8),
                  !password.isEmpty, let passwordData = self.password.data(using: .utf8)
            else {
                throw .missingData
            }
            
            let (serverPublicKeyID, publicKey, sharedKey) = try await SecureServerComunication.shared.getPublicAndSharedKey()
            
            let encryptedPassword = try Encryptor.encrypt(passwordData, with: sharedKey)
            
            let loginRequest = LoginRequest(
                clientPublicKey: .init(id: serverPublicKeyID, publicKey: publicKey.rawRepresentation),
                email: self.email,
                password: encryptedPassword
            )
            
            return loginRequest
        }
        
        private func encode(_ loginRequest: LoginRequest) throws(ExecutionError) -> Data {
            do {
                return try JSONEncoder().encode(loginRequest)
            } catch {
                throw .encodeFailure
            }
        }
        
        private func makeLogin(
            loginRequestData: Data,
            session: URLSession
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .api, path: .login),
                httpMethod: .post,
                headers: [EndpointBuilder.Header.contentType.rawValue: EndpointBuilder.HeaderValue.json.rawValue],
                body: loginRequestData
            )
            
            let handler = NetworkHandler<ExecutionError>(
                endpoint: endpoint,
                session: session,
                unkwnonURLRequestError: .internalError,
                failureToGetDataError: .failedToGetData
            )
            
            return try await handler.getResponse()
        }
        
        private func decode(_ loginResponseData: Data) throws(ExecutionError) -> LoginResponse {
            do {
                return try JSONDecoder().decode(LoginResponse.self, from: loginResponseData)
            } catch {
                throw .decodedFailure
            }
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
            await MainActor.run {
                self.error = error
            }
        }
        
        private func getServerPublicKey() {
            Task {
                do {
                    try await SecureServerComunication.shared.getKey()
                } catch let error as ExecutionError{
                    await setError(error)
                }
            }
        }
        
        init() { self.getServerPublicKey() }
    }
}
