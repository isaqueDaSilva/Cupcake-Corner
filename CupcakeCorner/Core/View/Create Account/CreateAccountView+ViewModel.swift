//
//  CreateAccountView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import Foundation

extension CreateAccountView {
    @Observable
    @MainActor
    final class ViewModel {
        var name = ""
        var email = ""
        var password = ""
        var confirmPassword = ""
        var isLoading = false
        var error: AppAlert? = nil
        
        private let logger = AppLogger(category: "CreateAccount+ViewModel")
        
        func createAccount(
            with session: URLSession = .shared,
            completation: @escaping (SignUpResponse, PrivateKey, URLSession) throws -> Void
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let (serverPublicKeyID, publicKey, sharedKey) = try await SecureServerComunication.getPublicAndSharedKey(
                        with: session
                    )
                    
                    let refreshTokenKey = PrivateKey()
                    
                    let encryptedPassword = try self.encryptPassword(with: sharedKey)
                    
                    let keyCollection = KeyCollection(
                        keyPairForDecryption: .init(
                            privateKeyID: serverPublicKeyID,
                            publicKey: publicKey.rawRepresentation
                        ),
                        publicKeyForEncryption: refreshTokenKey.publicKey.rawRepresentation
                    )
                    
                    let signupResponse = try await SignUpResponse.signUp(
                        with: self.name,
                        email: self.email,
                        encryptedPassword: encryptedPassword,
                        keyCollection: keyCollection,
                        and: session
                    )
                    
                    try await MainActor.run {
                        try completation(signupResponse, refreshTokenKey, session)
                    }
                } catch {
                    self.logger.error("Failed to create account with error: \(error.localizedDescription)")
                    await self.setError(.init(title: "Failed to create Account", description: ""))
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                }
            }
        }
        
        private func encryptPassword(with sharedKey: SymmetricKey) throws -> Data {
            guard let passwordData = self.password.data(using: .utf8) else {
                throw AppAlert.missingData
            }
            
            return try Encryptor.encrypt(passwordData, with: sharedKey)
        }
        
        private func checkResponse(_ response: Response) throws {
            guard response.status == .ok else {
                throw AppAlert.badResponse
            }
        }
        
        private func setError(_ error: AppAlert) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
    }
}
