//
//  CreateAccountView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension CreateAccountView {
    @Observable
    @MainActor
    final class ViewModel {
        var newUser = User.Create()
        var isLoading = false
        var error: ExecutionError? = nil
        var isShowingCreateAccountConfirmation = false
        
        func createAccount(session: URLSession = .shared) {
            self.isLoading = true
            
            Task {
                do {
                    let credentialsData = try encodeCredentials()
                    let (_, response) = try await performCreation(
                        with: credentialsData,
                        and: session
                    )
                    
                    try checkResponse(response)
                    
                    await MainActor.run {
                        self.isShowingCreateAccountConfirmation = true
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
        
        private func encodeCredentials() throws(ExecutionError) -> Data {
            do {
                return try JSONEncoder().encode(newUser)
            } catch {
                throw error as? ExecutionError ?? .internalError
            }
        }
        
        private func performCreation(
            with credentialsData: Data,
            and session: URLSession
        ) async throws -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .user, path: .create),
                httpMethod: .post,
                headers: [EndpointBuilder.Header.contentType.rawValue: EndpointBuilder.HeaderValue.json.rawValue],
                body: credentialsData
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
    }
}
