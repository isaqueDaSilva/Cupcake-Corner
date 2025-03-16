//
//  LoginView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

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
        
        func performLogin(completation: @escaping (User.Get) throws -> Void) {
            self.isLoading = true
            
            Task {
                do {
                    guard let credentials = makeCredentials() else {
                        throw ExecutionError.missingData
                    }
                    
                    let (data, response) = try await makeLogin(credentials: credentials)
                    
                    try checkResponse(response)
                    
                    let loginResponse = try decode(data)
                    
                    try storeToken(loginResponse.jwtToken)
                    
                    try await MainActor.run {
                        try completation(loginResponse.userProfile)
                    }
                } catch {
                    await MainActor.run {
                        self.error = error as? ExecutionError
                    }
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func makeCredentials() -> String? {
            guard !email.isEmpty && !password.isEmpty else { return nil }
            
            let loginData = ("\(email):\(password)".data(using: .utf8)?.base64EncodedString())
            let basicValue = EndpointBuilder.Header.basic
            
            guard let loginData else { return nil }
            
            return "\(basicValue) \(loginData)"
        }
        
        private func makeLogin(
            credentials: String,
            session: URLSession = .shared
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .api, path: .login),
                httpMethod: .post,
                headers: [EndpointBuilder.Header.authorization.rawValue: credentials]
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
    }
}
