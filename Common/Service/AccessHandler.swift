//
//  AccessHandler.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import CryptoKit
import Foundation
import SwiftData

@Observable
@MainActor
final class AccessHandler {
    private let logger = AppLogger(category: "AccessHandler")
    private var accessTokenObserverTask: Task<Void, Never>? = nil
    private var user: User? = nil
    
    /// A property that indicates that an action like,loading an user from persistent storage
    /// refresh or revocation their token or even deleting the user is happening on the background.
    var isPerfomingAction = false
    var alert: AppAlert? = nil
    var userProfile: UserProfile? { self.user?.profile }
    
    func fillStorange(with response: SignInAndSignUpResponse, privateKey: PrivateKey, context: ModelContext, session: URLSession) throws {
        let currentAccessTokenExpirationTime = response.tokens.accessToken.expirationTime
        let currentRefreshTokenExpirationTime = response.tokens.refreshToken.expirationTime
        
        try self.storeTokens(tokenPair: response.tokens, clientPrivateKey: privateKey)
        
        let newUser = User(
            with: response.profile,
            currentAccessTokenExpirationTime: currentAccessTokenExpirationTime,
            currentRefreshTokenExpirationTime: currentRefreshTokenExpirationTime
        )
        
        context.insert(newUser)
        try context.save()
        
        self.user = newUser
        
        self.observerExpirationTimeOfAccessToken(with: context, session: session)
    }
    
    func load(modelContext: ModelContext, session: URLSession) throws {
        self.isPerfomingAction = true
        
        defer {
            self.isPerfomingAction = false
        }
        
        let user = try self.fetchFromStorage(with: modelContext)
        
        guard (TokenHandler.getTokenValue(with: .accessToken) != nil) &&
               (TokenHandler.getTokenValue(with: .refreshToken) != nil)
        else {
            return try self.deleteRegistersOfUser(with: modelContext)
        }
        
        guard user.currentRefreshTokenExpirationTime > Date() else {
            Task { [weak self] in
                guard let self else { return }
                try await self.revokeAccess(with: modelContext, session: session)
            }
            
            return
        }
        
        guard user.currentAccessTokenExpirationTime > Date() else {
            Task { [weak self] in
                guard let self else { return }
                try await self.refreshAccessToken(with: session)
            }
            
            return
        }
        
        self.user = user
        self.observerExpirationTimeOfAccessToken(with: modelContext, session: session)
    }
    
    func revokeAccess(with revokeType: RevocationType, context: ModelContext, and session: URLSession) async throws {
        await MainActor.run { [weak self] in
            guard let self else { return }
            self.isPerfomingAction = true
        }
        
        
        guard let userProfile else {
            throw AppAlert.accessDenied
        }
        
        try await userProfile.performRevocation(with: revokeType, and: session)
        
        try await MainActor.run { [weak self] in
            guard let self else { return }
            
            try self.deleteRegistersOfUser(with: context)
            self.isPerfomingAction = false
        }
    }
}

extension AccessHandler {
    private func observerExpirationTimeOfAccessToken(with modelContext: ModelContext, session: URLSession) {
        self.accessTokenObserverTask?.cancel()
        
        self.accessTokenObserverTask = Task.detached { [weak self] in
            guard let self else { return }
            
            do {
                while let user = await self.userProfile {
                    guard user.currentRefreshTokenExpirationTime > Date() else {
                        return try await self.revokeAccess(with: modelContext, session: session)
                    }
                    
                    if user.currentAccessTokenExpirationTime > Date() {
                        let sleepTime = user.currentAccessTokenExpirationTime.timeIntervalSince(.now)
                        
                        let totalSleepTime = sleepTime > 60 ? sleepTime - 60 : 0
                        
                        try await Task.sleep(for: .seconds(totalSleepTime))
                    }
                    
                    try await self.refreshAccessToken(with: session)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.alert = .accessDenied
                }
            }
        }
        
    }
    
    private func refreshAccessToken(with session: URLSession) async throws {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.isPerfomingAction = true
        }
        
        guard let currentAccessToken = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true),
              let currentRefreshToken = TokenHandler.getTokenValue(with: .refreshToken, isWithBearerValue: false)
        else {
            throw AppAlert.accessDenied
        }
        
        let clientPrivateKey = PrivateKey()
        
        let tokenFields = TokenFields(
            accessToken: currentAccessToken,
            refreshToken: currentRefreshToken,
            publicKeyForEncryption: clientPrivateKey.publicKey.rawRepresentation
        )
        
        let (data, response) = try await tokenFields.refreshToken(with: session)
        
        try self.checkResponse(response)
        
        let tokenPair = try EncoderAndDecoder.decodeResponse(
            type: TokenPair.self,
            by: data
        )
        
        try self.storeTokens(
            tokenPair: tokenPair,
            clientPrivateKey: clientPrivateKey
        )
        
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.user?.currentAccessTokenExpirationTime = tokenPair.accessToken.expirationTime
            self.user?.currentRefreshTokenExpirationTime = tokenPair.refreshToken.expirationTime
            self.isPerfomingAction = false
        }
    }
    
    private func revokeAccess(with modelContext: ModelContext, session: URLSession) async throws {
        guard let currentAccessToken = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true),
              let currentRefreshToken = TokenHandler.getTokenValue(with: .refreshToken, isWithBearerValue: false)
        else {
            throw AppAlert.accessDenied
        }
        
        let tokens = [currentAccessToken, currentRefreshToken]
        
        let tokensData = try EncoderAndDecoder.encodeData(tokens)
        
        let (_, response) = try await Network(
            method: .delete,
            scheme: .https,
            path: "/auth/revoke-access",
            fields: [
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .upload(tokensData)
        ).getResponse(with: session)
        
        try self.checkResponse(response)
        
        try await MainActor.run { [weak self] in
            guard let self else { return }
            try self.deleteRegistersOfUser(with: modelContext)
        }
    }
    
    private func fetchFromStorage(with modelContext: ModelContext) throws -> User {
        let descriptor = User.fetchDescriptor
        let users = try modelContext.fetch(descriptor)
        
        guard users.count == 1 else { throw AppAlert.modelQuantityDifferent }
        
        return users[0]
    }
    
    private func deleteRegistersOfUser(with context: ModelContext) throws {
        let user = try self.fetchFromStorage(with: context)
        context.delete(user)
        try context.save()
        self.user = nil
        
        try KeychainService.delete(with: SecureFieldType.accessToken.rawValue)
        try KeychainService.delete(with: SecureFieldType.refreshToken.rawValue)
        
        self.accessTokenObserverTask?.cancel()
        
        self.alert = .init(
            title: "Session Expired",
            description: "Your session was expired. To continue to use the app, reconnect in your account."
        )
    }
}

extension AccessHandler {
    private func storeTokens(
        tokenPair: TokenPair,
        clientPrivateKey: PrivateKey
    ) throws {
        let decryptedRefreshToken = try self.decryptRefreshToken(
            encryptedRefreshToken: tokenPair.refreshToken.token,
            clientPrivateKey: clientPrivateKey,
            serverPublicKey: PublicKey(
                rawRepresentation: tokenPair.publicKey
            )
        )
        
        try TokenHandler.storePair(
            accessToken: tokenPair.accessToken,
            refreshToken: .init(
                token: decryptedRefreshToken,
                expirationTime: tokenPair.refreshToken.expirationTime
            )
        )
    }
    
    private func decryptRefreshToken(
        encryptedRefreshToken: String,
        clientPrivateKey: PrivateKey,
        serverPublicKey: PublicKey
    ) throws -> String {
        let sharedKey = try clientPrivateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)
        
        let symmetricKey = sharedKey.x963DerivedSymmetricKey(
            using: SHA512.self,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        guard let decryptedRefreshToken = try Decryptor.decrypt(field: encryptedRefreshToken, with: symmetricKey) else {
            throw AppAlert.failedToGetData
        }
        
        return decryptedRefreshToken
    }
    
    private func checkResponse(_ response: Response) throws {
        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw AppAlert.accessDenied
            } else {
                throw AppAlert.badResponse
            }
        }
    }
}
