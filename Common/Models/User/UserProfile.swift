//
//  UserProfile.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/30/25.
//

import Foundation

struct UserProfile: Sendable, Equatable {
    let id: UUID
    let name: String
    let email: String
    let currentAccessTokenExpirationTime: Date
    let currentRefreshTokenExpirationTime: Date
    
    init(by user: User) {
        self.id = user.id
        self.name = user.name
        self.email = user.email
        self.currentAccessTokenExpirationTime = user.currentAccessTokenExpirationTime
        self.currentRefreshTokenExpirationTime = user.currentRefreshTokenExpirationTime
    }
}

extension UserProfile {
    func performRevocation(with type: RevocationType, and session: URLSession) async throws {
        guard let accessToken = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true),
              let refreshToken = TokenHandler.getTokenValue(with: .refreshToken)
        else {
            throw AppAlert.accessDenied
        }
        
        let endpoint: String = switch type {
        case .signOut:
            "signout"
            #if CLIENT
        case .deleteAccount:
            "delete-account"
            #endif
        }
        
        let (_, response) = try await Network(
            method: .delete,
            scheme: .https,
            path: "/auth/\(endpoint)",
            fields: [
                .authorization : accessToken,
                .refreshToken! : refreshToken,
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .get
        ).getResponse(with: session)
        
        guard response.status == .ok else {
            throw AppAlert.badResponse
        }
    }
}
