//
//  ResponseMapping.swift
//  AI
//
//  Created by Kuragin Dmitriy on 10/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

enum SerializeError {
    case missingKey(String)
    case typeMismatch(String)
}

extension SerializeError: Error {}

protocol Serializer {
    associatedtype Source = [String: Any]
    associatedtype Destination
    
    func serialize(_ source: Source) throws -> Destination
}

func objectForKey<T>(_ key: String, dict: [String: Any], ignoreMissingKey: Bool = false) throws -> T {
    // TODO: The ignoreMissingKey is never used; remove if it's redundant.
    if let object = dict[key] {
        if let object = object as? T {
            return object
        } else {
            throw SerializeError.typeMismatch(key)
        }
    } else {
        throw SerializeError.missingKey(key)
    }
}

func objectForKeyOrNull<T>(_ key: String, dict: [String: Any]) -> T? {
    if let object = dict[key] {
        if let object = object as? T {
            return object
        } else {
            return .none
        }
    } else {
        return .none
    }
}

struct MessageSerializer: Serializer {
    typealias Destination = Message
    
    func serialize(_ source: Dictionary<String, Any>) throws -> Message {
        let type: Int = try objectForKey("type", dict: source)
        let speech: String = try objectForKey("speech", dict: source)
        
        return Message(type: type, speech: speech)
    }
}

struct FulfillmentSerializer: Serializer {
    typealias Destination = Fulfillment
    
    func serialize(_ source: FulfillmentSerializer.Source) throws -> FulfillmentSerializer.Destination {
        let speech: String = try objectForKey("speech", dict: source)
        
        let messageSerializer = MessageSerializer()
        
        let sourceMessages: [[String:Any]] = objectForKeyOrNull("messages", dict: source) ?? []
        
        let messages = try sourceMessages.map { (sourceMessage) -> Message in
            return try messageSerializer.serialize(sourceMessage)
        }
        
        return Destination(speech: speech, messages: messages)
    }
}

struct MetadataSerializer: Serializer {
    typealias Destination = Metadata
    
    func serialize(_ source: MetadataSerializer.Source) throws -> MetadataSerializer.Destination {
        let intentId: String? = objectForKeyOrNull("intentId", dict: source)
        let intentName: String? = objectForKeyOrNull("intentName", dict: source)
        
        return Destination(intentId: intentId, intentName: intentName)
    }
}

struct ContextSerializer: Serializer {
    typealias Destination = Context
    
    func serialize(_ source: ContextSerializer.Source) throws -> ContextSerializer.Destination {
        let name: String = try objectForKey("name", dict: source)
        let parameters: [String:Any] = try objectForKey("parameters", dict: source)
        
        return Destination(name: name, parameters: parameters)
    }
}

struct ResultSerializer: Serializer {
    typealias Destination = Result
    
    func serialize(_ source: ResultSerializer.Source) throws -> ResultSerializer.Destination {
        let sourceResult: String = try objectForKey("source", dict: source)
        let resolvedQuery: String = try objectForKey("resolvedQuery", dict: source)
        let action: String? = objectForKeyOrNull("action", dict: source)
        
        let parameters: [String:Any]? = try? objectForKey("parameters", dict: source)
        
        let contextsArray: [[String:Any]]? = try? objectForKey("contexts", dict: source)
        let contextSerializer = ContextSerializer()
        
        let contexts = try contextsArray.map { (object) -> [Context] in
            try object.map({ (object) -> Context in
                try contextSerializer.serialize(object)
            })
        }
        
        let fulfillmentObject: [String:Any]? = try? objectForKey("fulfillment", dict: source)
        
        let fulfillment = try fulfillmentObject.map({ (obj) -> Fulfillment in
            try FulfillmentSerializer().serialize(obj)
        })
        
        let metadata = try MetadataSerializer().serialize(try objectForKey("metadata", dict: source))
        
        return Destination(
            source: sourceResult,
            resolvedQuery: resolvedQuery,
            action: action,
            parameters: parameters,
            contexts: contexts,
            fulfillment: fulfillment,
            metadata: metadata
        )
    }
}

struct ResponseSerializer: Serializer {
    typealias Destination = QueryResponse
    
    func serialize(_ source: ResponseSerializer.Source) throws -> ResponseSerializer.Destination {
        let identifier: String = try objectForKey("id", dict: source)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        guard let timestamp: Date = dateFormatter.date(from: try objectForKey("timestamp", dict: source)) else {
            throw SerializeError.typeMismatch("timestamp")
        }
        
        let result = try ResultSerializer().serialize(try objectForKey("result", dict: source))
    
        return Destination(
            identifier: identifier,
            timestamp: timestamp,
            result: result
        )
    }
}
