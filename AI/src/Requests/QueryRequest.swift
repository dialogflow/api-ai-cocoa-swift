//
//  QueryRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 13/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public enum Language {
    case english
    case spanish
    case russian
    case german
    case portuguese
    case portuguese_Brazil
    case french
    case italian
    case japanese
    case korean
    case chinese_Simplified
    case chinese_HongKong
    case chinese_Taiwan
}

extension Language {
    var stringValue: String {
        switch self {
        case .english:
            return "en"
        case .spanish:
            return "es"
        case .russian:
            return "ru"
        case .german:
            return "de"
        case .portuguese:
            return "pt"
        case .portuguese_Brazil:
            return "pt-BR"
        case .french:
            return "fr"
        case .italian:
            return "it"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .chinese_Simplified:
            return "zh-CN"
        case .chinese_HongKong:
            return "zh-HK"
        case .chinese_Taiwan:
            return "zh-TW"
        }
    }
}

public protocol QueryRequest: Request {
    associatedtype ResponseType = QueryResponse
    
    var queryParameters: QueryParameters { get }
    var language: Language { get }
}

extension QueryRequest where Self: QueryContainer {
    func query() -> String {
        return "v=20150910"
    }
}

public struct Entry {
    public var value: String
    public var synonyms: [String]
}

public struct Entity {
    public var id: String? = .none
    public var name: String
    public var entries: [Entry]
}

public struct QueryParameters {
    public var contexts: [Context] = []
    public var resetContexts: Bool = false
    public var sessionId: String? = SessionStorage.defaultSessionIdentifier
    public var timeZone: TimeZone? = TimeZone.autoupdatingCurrent
    public var entities: [Entity] = []
    
    public init() {}
}

extension QueryParameters {
    func jsonObject() -> [String: Any] {
        var parameters = [String: Any]()
        
        parameters["contexts"] = contexts.map({ (context) -> [String: Any] in
            return ["name": context.name, "parameters": context.parameters]
        })
        
        parameters["resetContexts"] = resetContexts
        
        if let sessionId = sessionId {
            parameters["sessionId"] = sessionId
        }
        
        if let timeZone = timeZone {
            parameters["timezone"] = timeZone.identifier
        }
        
        parameters["entities"] = entities.map({ (entity) -> [String: Any] in
            var entityObject = [String: Any]()
            
            entityObject["name"] = entity.name
            entityObject["entries"] = entity.entries.map({ (entry) -> [String:Any] in
                ["value": entry.value, "synonyms": entry.synonyms]
            })
            
            return entityObject
        })
        
        return parameters
    }
}
