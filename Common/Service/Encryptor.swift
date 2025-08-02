//
//  Encryptor.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/20/25.
//

import CryptoKit
import Foundation

enum Encryptor {
    static func encrypt(_ field: Data, with sharedKey: SymmetricKey) throws(AppAlert) -> Data {
        do {
            let sealedBox = try AES.GCM.seal(field, using: sharedKey, nonce: .init())
            
            guard let combinedData = sealedBox.combined else {
                throw AppAlert.missingData
            }
            
            return combinedData
        } catch let appError as AppAlert {
            throw appError
        } catch {
            throw .internalError
        }
    }
}
