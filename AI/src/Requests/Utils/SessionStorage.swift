//
//  SessionStorage.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/03/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import Foundation

fileprivate let kSessionIdentifierStoreKey = "kSessionIdentifierStoreKey"

public struct SessionStorage {
    public static var defaultSessionIdentifier: String = SessionStorage.retrieveDefaultSessionIdentifier()
    
    fileprivate static func retrieveDefaultSessionIdentifier() -> String {
        let userDefaults = UserDefaults.standard
        
        if let storedSessionIdentifier = userDefaults.object(forKey: kSessionIdentifierStoreKey) as? String {
            return storedSessionIdentifier
        } else {
            let generatedSessionIdentifier = NSUUID().uuidString

            userDefaults.set(generatedSessionIdentifier, forKey: kSessionIdentifierStoreKey)
            userDefaults.synchronize()
            
            return generatedSessionIdentifier
        }

    }
}
