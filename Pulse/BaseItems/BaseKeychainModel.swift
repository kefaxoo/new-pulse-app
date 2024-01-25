//
//  BaseKeychainModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation
import Security

class BaseKeychainModel {
    let service: String
    
    init(service: String) {
        self.service = service
    }
    
    func saveCredentials(_ credentials: Credentials) -> Bool {
        guard let passwordData = credentials.password?.data(using: .utf8) else { return false }
        
        let attributes: [String: Any] = [
            kSecClass as String      : kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: credentials.username,
            kSecValueData as String  : passwordData
        ]
        
        return SecItemAdd(attributes as CFDictionary, nil) == noErr
    }
    
    func getCredentials(username: String) -> Credentials? {
        let query: [String: Any] = [
            kSecClass as String           : kSecClassGenericPassword,
            kSecAttrService as String     : self.service,
            kSecAttrAccount as String     : username,
            kSecMatchLimit as String      : kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String      : true
        ]
        
        var item: CFTypeRef?
        
        guard SecItemCopyMatching(query as CFDictionary, &item) == noErr,
              let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8)
        else { return nil }
        
        return Credentials(username: username, password: password)
    }
    
    func updatePassword(credentials: Credentials) -> Bool {
        guard let passwordData = credentials.password?.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String      : kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: credentials.username
        ]
        
        let attributes: [String: Any] = [kSecValueData as String: passwordData]
        
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr
    }
    
    @discardableResult func deleteAccount(username: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String      : kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: username
        ]
        
        return SecItemDelete(query as CFDictionary) == noErr
    }
}
