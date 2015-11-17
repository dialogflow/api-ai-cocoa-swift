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
    case UnknownError
    
    case ResponseSerializeMissingKey
    case ResponseSerializeTypeMismatch
    case ResponseBodyEmpty
    
    case RequestSerializeMissingKey
    case RequestSerializeTypeMismatch
    
    case ResponseObjectEmpty
    case ResponseDataEmpty
    case MIMETypeEmpty
    case UnexpectedMIMEType
    case WrongResponseObjectType
    
    case RequestUserCancelled
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
            NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
        ]
        
        self.init(domain: NSURLErrorDomain, code: statusCode, userInfo: userInfo)
    }
}

internal extension NSError {
    convenience init(forErrorString errorString: String) {
        self.init(code: AIErrorCode.UnknownError, message: errorString)
    }
}