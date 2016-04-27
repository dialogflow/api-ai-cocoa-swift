//
//  ResponseMapping.swift
//  AI
//
//  Created by Kuragin Dmitriy on 10/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

enum SerializeError {
    case MissingKey(String)
    case TypeMismatch(String)
}

extension SerializeError: ErrorType {}
extension SerializeError: CompletionError {
    func asNSError() -> NSError {
        switch self {
        case .MissingKey(let key):
            return NSError(forErrorString: "Missing key: \(key)")
        case .TypeMismatch(let info):
            return NSError(forErrorString: "Type mismatch: \(info)")
        }
    }
}

protocol Serializer {
    associatedtype Source = [String: AnyObject]
    associatedtype Destination
    
    func serialize(source: Source) throws -> Destination
}

func objectForKey<T>(key: String, dict: [String: AnyObject], ignoreMissingKey: Bool = false) throws -> T {
    // TODO: The ignoreMissingKey is never used; remove if it's redundant.
    if let object = dict[key] {
        if let object = object as? T {
            return object
        } else {
            throw SerializeError.TypeMismatch(key)
        }
    } else {
        throw SerializeError.MissingKey(key)
    }
}

func objectForKeyOrNull<T>(key: String, dict: [String: AnyObject]) -> T? {
    if let object = dict[key] {
        if let object = object as? T {
            return object
        } else {
            return .None
        }
    } else {
        return .None
    }
}

struct FulfillmentSerializer: Serializer {
    typealias Destination = Fulfillment
    
    func serialize(source: FulfillmentSerializer.Source) throws -> FulfillmentSerializer.Destination {
        let speech: String = try objectForKey("speech", dict: source)
        
        return Destination(speech: speech)
    }
}

struct MetadataSerializer: Serializer {
    typealias Destination = Metadata
    
    func serialize(source: MetadataSerializer.Source) throws -> MetadataSerializer.Destination {
        let intentId: String? = objectForKeyOrNull("intentId", dict: source)
        let intentName: String? = objectForKeyOrNull("intentName", dict: source)
        
        return Destination(intentId: intentId, intentName: intentName)
    }
}

struct ContextSerializer: Serializer {
    typealias Destination = Context
    
    func serialize(source: ContextSerializer.Source) throws -> ContextSerializer.Destination {
        let name: String = try objectForKey("name", dict: source)
        let parameters: [String:AnyObject] = try objectForKey("parameters", dict: source)
        
        return Destination(name: name, parameters: parameters)
    }
}

struct ResultSerializer: Serializer {
    typealias Destination = Result
    
    func serialize(source: ResultSerializer.Source) throws -> ResultSerializer.Destination {
        let sourceResult: String = try objectForKey("source", dict: source)
        let resolvedQuery: String = try objectForKey("resolvedQuery", dict: source)
        let action: String? = objectForKeyOrNull("action", dict: source)
        
        let parameters: [String:AnyObject]? = try? objectForKey("parameters", dict: source)
        
        let contextsArray: [[String:AnyObject]]? = try? objectForKey("contexts", dict: source)
        let contextSerializer = ContextSerializer()
        
        let contexts = try contextsArray.map { (object) -> [Context] in
            try object.map({ (object) -> Context in
                try contextSerializer.serialize(object)
            })
        }
        
        let fulfillmentObject: [String:AnyObject]? = try? objectForKey("fulfillment", dict: source)
        
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
    
    func serialize(source: ResponseSerializer.Source) throws -> ResponseSerializer.Destination {
        let identifier: String = try objectForKey("id", dict: source)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        guard let timestamp: NSDate = dateFormatter.dateFromString(try objectForKey("timestamp", dict: source)) else {
            throw SerializeError.TypeMismatch("timestamp")
        }
        
        let result = try ResultSerializer().serialize(try objectForKey("result", dict: source))
    
        return Destination(
            identifier: identifier,
            timestamp: timestamp,
            result: result
        )
    }
}