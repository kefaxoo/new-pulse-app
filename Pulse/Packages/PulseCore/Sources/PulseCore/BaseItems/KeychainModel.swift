//
//  KeychainModel.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import Foundation
import Security

public class KeychainModel {
    let service: String
    
    public init(service: String) {
        self.service = service
    }
    
    @discardableResult public func saveCredentials(_ credentials: Credentials) -> Bool {
        guard let passwordData = credentials.password?.data(using: .utf8) else { return false }
        
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: credentials.username,
            kSecValueData as String: passwordData
        ]
        
        return SecItemAdd(attributes as CFDictionary, nil) == noErr
    }
    
    public func getCredentials(forUsername username: String) -> Credentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: username,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        
        guard SecItemCopyMatching(query as CFDictionary, &item) == noErr,
              let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8)
        else { return nil }
        
        return Credentials(username: username, password: password)
    }
    
    @discardableResult public func updatePassword(credentials: Credentials) -> Bool {
        guard let passwordData = credentials.password?.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: credentials.username
        ]
        
        let attributes: [String: Any] = [kSecValueData as String: passwordData]
        
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr
    }
    
    @discardableResult public func deleteAccount(username: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: username
        ]
        
        return SecItemDelete(query as CFDictionary) == noErr
    }
    
    @discardableResult public func saveOrUpdateAccount(credentials: Credentials) -> Bool {
        if self.getCredentials(forUsername: credentials.username) != nil {
            return self.updatePassword(credentials: credentials)
        } else {
            return self.saveCredentials(credentials)
        }
    }
}
