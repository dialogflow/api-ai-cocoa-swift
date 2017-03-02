//
//  Response.swift
//  api
//
//  Created by Kuragin Dmitriy on 06/10/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public struct Message {
    public let type: Int
    public let speech: String
}

public struct Fulfillment {
    public let speech: String
    public let messages: [Message]
}

public struct Metadata {
    public let intentId: String?
    public let intentName: String?
}

public struct Context {
    public let name: String
    public let parameters: [String: Any]
}

public struct Result {
    public let source: String
    public let resolvedQuery: String
    public let action: String?
    
    public let parameters: [String: Any]?
    public let contexts: [Context]?
    
    public let fulfillment: Fulfillment?
    public let metadata: Metadata
}

public struct QueryResponse {
    public let identifier: String
    public let timestamp: Date

    public let result: Result
}
