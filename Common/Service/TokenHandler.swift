//
//  TokenGetter.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

enum TokenHandler {
    static func storePair(accessToken: Token, refreshToken: Token) throws {
        _ = try KeychainService.store(accessToken, key: SecureFieldType.accessToken.rawValue)
        _ = try KeychainService.store(refreshToken, key: SecureFieldType.refreshToken.rawValue)
    }
    
    static func getTokenValue(with key: SecureFieldType, isWithBearerValue: Bool = false) -> String? {
        guard let tokenValue = try? KeychainService.retrive(Token.self, for: key.rawValue) else {
            return nil
        }
        
        if isWithBearerValue {
            return "Bearer \(tokenValue.token)"
        } else {
            return tokenValue.token
        }
    }
}
