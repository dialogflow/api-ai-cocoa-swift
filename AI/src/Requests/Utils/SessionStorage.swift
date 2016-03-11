//
//  SessionStorage.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/03/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public struct SessionStorage {
    public static var defaultSessionIdentifier: String {
        struct Static {
            static var kSessionIdentifierStoreKey = "kSessionIdentifierStoreKey"
            static var defaultSessionIdentifier: String? = .None
            static var dispatch_once_token: dispatch_once_t = 0
        }
        
        
        dispatch_once(&Static.dispatch_once_token) { () -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if let storedSessionIdentifier = userDefaults.objectForKey(Static.kSessionIdentifierStoreKey) as? String {
                Static.defaultSessionIdentifier = storedSessionIdentifier
            } else {
                let generatedSessionIdentifier = NSUUID().UUIDString
                
                userDefaults.setObject(generatedSessionIdentifier, forKey: Static.kSessionIdentifierStoreKey)
                userDefaults.synchronize()
            
                Static.defaultSessionIdentifier = generatedSessionIdentifier
            }
        }
        
        return Static.defaultSessionIdentifier!
    }
}