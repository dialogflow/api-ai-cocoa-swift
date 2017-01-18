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
    case object(JSONObject)
    case array(JSONArray)
    case number(JSONNumber)
    case jString(JSONString)
    
    case null
    case none
    
    init(_ object: JSONAny?) {
        self.init(object: object)
    }
    
    init(object: JSONAny?) {
        if let object = object {
            switch object {
            case let object as JSONObject:
                self = .object(object)
            case let object as JSONArray:
                self = .array(object)
            case let object as JSONNumber:
                self = .number(object)
            case let object as JSONString:
                self = .jString(object)
            case _ as JSONNull:
                self = .null
            default:
                self = .none
            }
        } else {
            self = .none
        }
    }
    
    subscript(index: Int) -> JSON {
        get {
            if case .array(let array) = self {
                if index >= 0 && index < array.count {
                    return JSON(array[index])
                }
                
                return .none
            }
            
            return .none
        }
    }
    
    subscript(key: String) -> JSON {
        get {
            if case .object(let object) = self {
                return JSON(object[key])
            }
            
            return .none
        }
    }
}

extension JSON {
    var string: String? {
        if case .jString(let object) = self {
            return object
        }
        
        return .none
    }
    
    var int: Int? {
        if case .number(let object) = self {
            return object.intValue
        }
        
        return .none
    }
}
