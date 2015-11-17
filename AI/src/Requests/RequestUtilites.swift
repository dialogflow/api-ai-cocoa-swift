//
//  RequestUtilites.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

func handle(data: NSData?, _ response: NSURLResponse?, _ error: NSError?) -> Completion<NSData> {
    if let error = error {
        return .Failure(error)
    }
    
    guard response != .None else {
        return .Failure(NSError(code: .ResponseObjectEmpty, message: "NSURLResponse is empty."))
    }
    
    guard let response = response as? NSHTTPURLResponse else {
        return .Failure(NSError(code: .WrongResponseObjectType, message: "Wrong response type. Expected NSHTTPURLResponse."))
    }
    
    let acceptableStatusCodes = NSIndexSet(indexesInRange: NSRange(location: 200, length: 100))
    
    if !acceptableStatusCodes.containsIndex(response.statusCode) {
        return .Failure(NSError(forHTTPStatusCode: response.statusCode))
    }
    
    guard let mimeType = response.MIMEType else {
        return .Failure(NSError(code: .MIMETypeEmpty, message: "MIMEType connot be empty"))
    }
    
    let acceptableContentTypes = Set(arrayLiteral: "application/json", "text/json", "text/javascript")
    
    if !acceptableContentTypes.contains(mimeType) {
        return .Failure(NSError(code: .UnexpectedMIMEType, message: "Wrong MIMEType type: \(mimeType). Expected \(acceptableContentTypes)"))
    }
    
    guard let data = data else {
        return .Failure(NSError(code: .ResponseDataEmpty, message: "Response data is empty."))
    }
    
    return .Success(data)
}

func serializeJSON(data: NSData) -> Completion<AnyObject> {
    do {
        let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        return .Success(object)
    } catch let error as NSError {
        return .Failure(error)
    }
}

func validateObject(object: AnyObject) -> Completion<[String: AnyObject]> {
    if let object = object as? [String: AnyObject] {
        if let code = JSON(object)["status"]["code"].int {
            if code == 200 {
                return .Success(object)
            } else {
                return .Failure(NSError(forHTTPStatusCode: code))
            }
        } else {
            return .Failure(SerializeError.MissingKey("status.code"))
        }
    } else {
        return .Failure(SerializeError.TypeMismatch("root"))
    }
}

func serializeObject(object: [String: AnyObject]) -> Completion<QueryResponse> {
    do {
        let response = try ResponseSerializer().serialize(object)
        return .Success(response)
    } catch let error as SerializeError {
        return .Failure(error.asNSError())
    } catch let error as NSError {
        return .Failure(error)
    }
}