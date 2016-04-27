//
//  Request.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public enum RequestCompletion<T> {
    case Success(T)
    case Failure(NSError)
}

extension Completion {
    func toRequestCompletion() -> RequestCompletion<A> {
        switch self {
        case .Success(let object):
            return .Success(object)
        case .Failure(let error):
            return .Failure(error.asNSError())
        }
    }
}

public protocol Request: class {
    var credentials: Credentials { get }
    var session: NSURLSession { get }
    
    associatedtype ResponseType
    
    func resume(completionHandler: (RequestCompletion<ResponseType>) -> Void) -> Self
    
    func cancel()
}

public extension Request {
    typealias SuccessCompletionHandler = (ResponseType) -> Void
    typealias FailureCompletionHandler = (NSError) -> Void
    
    func success(completionHandler: SuccessCompletionHandler) -> Self {
        return self.resume { (completion) -> Void in
            if case .Success(let object) = completion {
                completionHandler(object)
            }
        }
    }
    
    func failure(completionHandler: FailureCompletionHandler) -> Self {
        return self.resume { (completion) -> Void in
            if case .Failure(let error) = completion {
                completionHandler(error)
            }
        }
    }
}