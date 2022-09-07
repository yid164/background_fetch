//
//  KeychainManager.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-09-05.
//

import Foundation
import Security

public class KeychainManager {
    
    static func createKeychain(password: Data, service: String, account: String) {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        
        if status == errSecDuplicateItem {
            print("Error for duplicate")
        }
        
        if status == errSecSuccess {
            print("Keychain create success")
        } else {
            print("Keychain create error")
        }
    }
    
    static func updateKeychain(password: Data, service: String, account: String) {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData as String: password as AnyObject
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        if status == errSecSuccess {
            print("Keychain update success")
        } else {
            print("Keychain update error")
        }
    }
    
    static func removeKeychain(service: String, account: String) {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("Keychain remove success")
        } else {
            print("Keychain remove error")
        }
    }
    
    static func getKeychain(service: String, account: String) -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )
        
        if status == errSecSuccess {
            if let password = itemCopy as? Data {
                return password
            } else {
                return "Get Keychain Error".data(using: .utf8)!
            }
        } else {
            return "Get Keychain Error".data(using: .utf8)!
        }
    }
}
