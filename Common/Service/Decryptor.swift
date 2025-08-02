//
//  Decryptor.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/29/25.
//

import CryptoKit
import Foundation

enum Decryptor {
    static func decrypt(field: String, with sharedKey: SymmetricKey) throws -> String? {
        guard let encryptedFieldData = field.data(using: .utf8) else { throw AppAlert.internalError }
        
        let sealBox = try AES.GCM.SealedBox(combined: encryptedFieldData)
        let decryptSealBox = try AES.GCM.open(sealBox, using: sharedKey)
        
        return String(data: decryptSealBox, encoding: .utf8)
    }
}
