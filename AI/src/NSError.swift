//
//  NSError.swift
//  AI
//
//  Created by Kuragin Dmitriy on 10/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public let AIErrorDomain: String = "AIErrorDomain"

public enum AIErrorCode: Int {
    case unknownError
    
    case responseSerializeMissingKey
    case responseSerializeTypeMismatch
    case responseBodyEmpty
    
    case requestSerializeMissingKey
    case requestSerializeTypeMismatch
    
    case responseObjectEmpty
    case responseDataEmpty
    case mimeTypeEmpty
    case unexpectedMIMEType
    case wrongResponseObjectType
    
    case requestUserCancelled
}

internal extension NSError {
    convenience init(code: AIErrorCode, message: String) {
        let userInfo = [
            NSLocalizedDescriptionKey: message
        ]
        
        self.init(domain: AIErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

internal extension NSError {
    convenience init(forHTTPStatusCode statusCode: Int) {
        let userInfo = [
            NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)
        ]
        
        self.init(domain: NSURLErrorDomain, code: statusCode, userInfo: userInfo)
    }
}

internal extension NSError {
    convenience init(forErrorString errorString: String) {
        self.init(code: AIErrorCode.unknownError, message: errorString)
    }
}
