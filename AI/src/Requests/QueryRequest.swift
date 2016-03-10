//
//  QueryRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 13/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public enum Language {
    case English // en
    case Spanish // es
    case Russian // ru
    case German // de
    case Portuguese // pt
    case Portuguese_Brazil // pt_br
    case French /
    case Italian
    case Japanese
    case Korean
    case Chinese_Simplified
    case Chinese_HongKong
    case Chinese_Taiwan
}

extension Language {
    var stringValue: String {
        switch self {
        case .English:
            return "en"
        case .Spanish:
            return "es"
        case .Russian:
            return "ru"
        case .German:
            return "de"
        case .Portuguese:
            return "pt"
        case .Portuguese_Brazil:
            return "pt-BR"
        case .French:
            return "fr"
        case .Italian:
            return "it"
        case .Japanese:
            return "ja"
        case .Korean:
            return "ko"
        case .Chinese_Simplified:
            return "zh-CN"
        case .Chinese_HongKong:
            return "zh-HK"
        case .Chinese_Taiwan:
            return "zh-TW"
        }
    }
}

public protocol QueryRequest: Request {
    typealias ResponseType = QueryResponse
    
    var queryParameters: QueryParameters { get }
    var language: Language { get }
}

public struct Entry {
    public var value: String
    public var synonyms: [String]
}

public struct Entity {
    public var id: String? = .None
    public var name: String
    public var entries: [Entry]
}

public struct QueryParameters {
    public var contexts: [Context] = []
    public var resetContexts: Bool = false
    public var sessionId: String? = nil
    public var timeZone: NSTimeZone? = NSTimeZone.localTimeZone()
    public var entities: [Entity] = []
    
    public init() {}
}

extension QueryParameters {
    func jsonObject() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        
        parameters["contexts"] = contexts.map({ (context) -> [String: AnyObject] in
            return ["name": context.name, "parameters": context.parameters]
        })
        
        parameters["resetContexts"] = resetContexts
        
        if let sessionId = sessionId {
            parameters["sessionId"] = sessionId
        }
        
        if let timeZone = timeZone {
            parameters["timezone"] = timeZone.name
        }
        
        parameters["entities"] = entities.map({ (entity) -> [String: AnyObject] in
            var entityObject = [String: AnyObject]()
            
            entityObject["name"] = entity.name
            entityObject["entries"] = entity.entries.map({ (entry) -> [String:AnyObject] in
                ["value": entry.value, "synonyms": entry.synonyms]
            })
            
            return entityObject
        })
        
        return parameters
    }
}
