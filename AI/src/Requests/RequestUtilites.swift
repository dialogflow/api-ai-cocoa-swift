//
//  RequestUtilites.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

func handle(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Completion<Data> {
    if let error = error {
        return .failure(error)
    }
    
    guard response != .none else {
        return .failure(NSError(code: .responseObjectEmpty, message: "NSURLResponse is empty."))
    }
    
    guard let response = response as? HTTPURLResponse else {
        return .failure(NSError(code: .wrongResponseObjectType, message: "Wrong response type. Expected NSHTTPURLResponse."))
    }
    
    let acceptableStatusCodes = IndexSet(integersIn: NSRange(location: 200, length: 100).toRange() ?? 0..<0)
    
    if !acceptableStatusCodes.contains(response.statusCode) {
        return .failure(NSError(forHTTPStatusCode: response.statusCode))
    }
    
    guard let mimeType = response.mimeType else {
        return .failure(NSError(code: .mimeTypeEmpty, message: "MIMEType connot be empty"))
    }
    
    let acceptableContentTypes = Set(arrayLiteral: "application/json", "text/json", "text/javascript")
    
    if !acceptableContentTypes.contains(mimeType) {
        return .failure(NSError(code: .unexpectedMIMEType, message: "Wrong MIMEType type: \(mimeType). Expected \(acceptableContentTypes)"))
    }
    
    guard let data = data else {
        return .failure(NSError(code: .responseDataEmpty, message: "Response data is empty."))
    }
    
    return .success(data)
}

func serializeJSON(_ data: Data) -> Completion<Any> {
    do {
        let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
        return .success(object)
    } catch let error as NSError {
        return .failure(error)
    }
}

func validateObject(_ object: Any) -> Completion<[String: Any]> {
    if let object = object as? [String: Any] {
        if let code = JSON(object as JSONAny?)["status"]["code"].int {
            if code == 200 {
                return .success(object)
            } else {
                return .failure(NSError(forHTTPStatusCode: code))
            }
        } else {
            return .failure(SerializeError.missingKey("status.code"))
        }
    } else {
        return .failure(SerializeError.typeMismatch("root"))
    }
}

func serializeObject(_ object: [String: Any]) -> Completion<QueryResponse> {
    do {
        let response = try ResponseSerializer().serialize(object)
        return .success(response)
    } catch let error {
        return .failure(error)
    }
}
