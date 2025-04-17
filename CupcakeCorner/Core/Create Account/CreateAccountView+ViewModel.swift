//
//  CreateAccountView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import CryptoKit
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
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let (serverPublicKeyID, publicKey, sharedKey) = try await SecureServerComunication.getPublicAndSharedKey(
                        with: session
                    )
                    
                    let credentialsData = try await encodeCredentials(
                        with: serverPublicKeyID,
                        publicKey: publicKey,
                        sharedKey: sharedKey
                    )
                    
                    let (_, response) = try await performCreation(
                        with: credentialsData,
                        and: session
                    )
                    
                    try Network.checkResponse(response)
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.isShowingCreateAccountConfirmation = true
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
        
        private func encodeCredentials(
            with serverPublicKeyID: UUID,
            publicKey: PublicKey,
            sharedKey: SymmetricKey
        ) async throws(ExecutionError) -> Data {
            try newUser.encryptCredentials(
                with: .init(
                    id: serverPublicKeyID,
                    publicKey: publicKey.rawRepresentation
                ),
                sharedKey: sharedKey
            )
            
            return try Network.encodeData(newUser)
        }
        
        private func performCreation(
            with credentialsData: Data,
            and session: URLSession
        ) async throws -> (Data, URLResponse) {
            try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .user, path: .create),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.contentType.rawValue: EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: credentialsData,
                session: session
            )
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
    }
}
