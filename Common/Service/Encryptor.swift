//
//  Encryptor.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/20/25.
//

import CryptoKit
import ErrorWrapper
import Foundation

enum Encryptor {
    static func encrypt(_ field: Data, with sharedKey: SymmetricKey) throws(ExecutionError) -> Data {
        do {
            let sealedBox = try AES.GCM.seal(field, using: sharedKey, nonce: .init())
            
            guard let combinedData = sealedBox.combined else {
                throw ExecutionError.missingData
            }
            
            return combinedData
        } catch let executionError as ExecutionError {
            throw executionError
        } catch {
            throw .internalError
        }
    }
}
