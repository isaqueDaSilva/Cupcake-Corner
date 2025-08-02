//
//  KeychainService.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/29/25.
//

import Foundation
import Security

/// An object for manage the operation of the Keychain.
public enum KeychainService {
    /// Stores a new item in the Keychain
    /// - Parameter token: An instance value of the item.
    @discardableResult
    public static func store<T: Codable>(_ model: T, key: String) throws -> OSStatus {
        // Checks if has some item saved.
        // If it has, will be executing a
        // delete action for clean the store.
        if try Self.hasSomeItemSaved(for: T.self, key: key) {
            _ = try delete(with: key)
        }
        
        // Encoding the token value.
        let encoder = JSONEncoder()
        let modelData = try encoder.encode(model)
        
        // Creating a query dictionary
        // for saving in the Keychain.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: modelData
        ]
        
        // Peforms the save action
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Checks the staus is equal to success.
        // If no equal, the save error is throwing.
        guard status == errSecSuccess else {
            throw AppAlert.internalError
        }
        
        return status
    }
    
    /// Unwrapping an item value saved in the keychain.
    /// - Returns: Returns the item's value saved.
    @discardableResult
    public static func retrive<T: Codable>(_ model: T.Type, for key: String) throws -> T? {
        // Creating a query dictionary
        // with some information about
        // how the search will be performed.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        // A property that stores a dictionary
        // when the search is finished with success.
        var item: CFTypeRef?
        
        // Perform a search action.
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // Checking if some item is found.
        guard status != errSecItemNotFound else {
            throw AppAlert.internalError
        }
        
        // Checking if the status is equal to success.
        guard status == errSecSuccess else {
            throw AppAlert.internalError
        }
        
        // Checking if has some item in the item variable
        // and unwrapping the value in the `kSecValueData` key.
        guard let existingItem = item as? [String: Any],
              let modelData = existingItem[kSecValueData as String] as? Data else {
            return nil
        }
        
        // Decoding the data into item type.
        let decoder = JSONDecoder()
        let model = try decoder.decode(model, from: modelData)
        
        return model
    }
    
    
    /// Deleting the item fromthe Keychain.
    @discardableResult
    public static func delete(with key: String) throws -> OSStatus {
        // Creating a query dictionary
        // with some information about
        // how the search the token on the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Deleting the dictionary with the corresponding
        // corresponding Token instance in the Keychain
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw AppAlert.internalError
        }
        
        return status
    }
    
    /// Checks if has some item saved in the Keychain.
    private static func hasSomeItemSaved<T: Codable>(for model: T.Type, key: String) throws -> Bool {
        try Self.retrive(model, for: key) != nil
    }
}
