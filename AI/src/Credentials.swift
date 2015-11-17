//
//  Credentials.swift
//  APII
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public struct Credentials {
    var clientAccessToken: String
    var subscribtionKey: String
    
    public init(_ clientAccessToken: String, _ subscribtionKey: String) {
        self.clientAccessToken = clientAccessToken
        self.subscribtionKey = subscribtionKey
    }
    
    public init(clientAccessToken: String, subscribtionKey: String) {
        self.clientAccessToken = clientAccessToken
        self.subscribtionKey = subscribtionKey
    }
}

private let kAuthorizationHTTPHeaderFieldName = "Authorization"
private let kSubscribtionKeyHTTPHeaderFieldName = "ocp-apim-subscription-key"

internal extension NSMutableURLRequest {
    func authenticate(credentials: Credentials) {
        self.addValue("Bearer \(credentials.clientAccessToken)", forHTTPHeaderField: kAuthorizationHTTPHeaderFieldName);
        self.addValue("\(credentials.subscribtionKey)", forHTTPHeaderField: kSubscribtionKeyHTTPHeaderFieldName)
    }
}