//
//  TokenGetter.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import Foundation
import KeychainService

enum TokenGetter {
    static func getValue(with token: Token? = nil) throws(ExecutionError) -> String {
        let bearerValue = EndpointBuilder.Header.bearer.rawValue
        
        if let tokenValue = token {
            return "\(bearerValue) \(tokenValue.token)"
        } else {
            do {
                let tokenValue = try KeychainService.retrive(Token.self)
                return "\(bearerValue) \(tokenValue.token)"
            } catch {
                throw .fetchFailed
            }
        }
    }
}
