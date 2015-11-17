//
//  JSON.swift
//  AI
//
//  Created by Kuragin Dmitriy on 06/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

typealias JSONAny = AnyObject
typealias JSONObject = [String: AnyObject]
typealias JSONArray = [AnyObject]
typealias JSONString = String
typealias JSONNumber = NSNumber
typealias JSONNull = NSNull

enum JSON {
    case Object(JSONObject)
    case Array(JSONArray)
    case Number(JSONNumber)
    case JString(JSONString)
    
    case Null
    case None
    
    init(_ object: JSONAny?) {
        self.init(object: object)
    }
    
    init(object: JSONAny?) {
        if let object = object {
            switch object {
            case let object as JSONObject:
                self = .Object(object)
            case let object as JSONArray:
                self = .Array(object)
            case let object as JSONNumber:
                self = .Number(object)
            case let object as JSONString:
                self = .JString(object)
            case _ as JSONNull:
                self = .Null
            default:
                self = .None
            }
        } else {
            self = .None
        }
    }
    
    subscript(index: Int) -> JSON {
        get {
            if case .Array(let array) = self {
                if index >= 0 && index < array.count {
                    return JSON(array[index])
                }
                
                return .None
            }
            
            return .None
        }
    }
    
    subscript(key: String) -> JSON {
        get {
            if case .Object(let object) = self {
                return JSON(object[key])
            }
            
            return .None
        }
    }
}

extension JSON {
    var string: String? {
        if case .JString(let object) = self {
            return object
        }
        
        return .None
    }
    
    var int: Int? {
        if case .Number(let object) = self {
            return object.integerValue
        }
        
        return .None
    }
}