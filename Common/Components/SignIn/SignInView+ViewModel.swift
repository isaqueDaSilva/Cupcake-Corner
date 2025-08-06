//
//  SignInView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import CryptoKit
import Foundation

extension SignInView {
    @Observable
    @MainActor
    final class ViewModel {
        var email = ""
        var password = ""
        
        var isLoading = false
        var error: AppAlert?
        
        func signIn(
            with session: URLSession = .shared,
            completation: @escaping (SignInResponse, PrivateKey, URLSession) throws -> Void
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let (serverPublicKeyID, publicKey, sharedKey) = try await SecureServerComunication.getPublicAndSharedKey(
                        with: session
                    )
                    
                    let refreshTokenKey = PrivateKey()
                    
                    let loginValue = try self.makeCredentials(
                        publicKey: publicKey,
                        sharedKey: sharedKey
                    )
                    
                    let keyCollection = KeyCollection(
                        keyPairForDecryption: .init(
                            privateKeyID: serverPublicKeyID,
                            publicKey: publicKey.rawRepresentation
                        ),
                        publicKeyForEncryption: refreshTokenKey.publicKey.rawRepresentation
                    )
                    
                    let keyCollectionData = try EncoderAndDecoder.encodeData(keyCollection)
                    
                    let signInResponse = try await SignInResponse.signIn(
                        with: loginValue,
                        keyCollectionData: keyCollectionData,
                        session: session
                    )
                    
                    try completation(signInResponse, refreshTokenKey, session)
                }
            }
        }
        
        private func setError(_ error: AppAlert) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
        
        private func makeCredentials(
            publicKey: PublicKey,
            sharedKey: SymmetricKey
        ) throws -> String {
            guard !self.email.isEmpty,!self.password.isEmpty,
                  let passwordData = self.password.data(using: .utf8)
            else {
                throw AppAlert.missingData
            }
            
            let encryptedPassword = try Encryptor.encrypt(passwordData, with: sharedKey).base64EncodedString()
            
            guard let loginValue = ("\(self.email):\(encryptedPassword)".data(using: .utf8))?.base64EncodedString() else {
                throw AppAlert.missingData
            }
            
            return loginValue
        }
    }
}
