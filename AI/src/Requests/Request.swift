//
//  Request.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public enum RequestCompletion<T> {
    case success(T)
    case failure(Error)
}

extension Completion {
    func toRequestCompletion() -> RequestCompletion<A> {
        switch self {
        case .success(let object):
            return .success(object)
        case .failure(let error):
            return .failure(error)
        }
    }
}

public protocol Request: class {
    var credentials: Credentials { get }
    var session: URLSession { get }
    
    associatedtype ResponseType
    
    @discardableResult
    func resume(completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void) -> Self
    
    func cancel()
}

public extension Request {
    typealias SuccessCompletionHandler = (ResponseType) -> Void
    typealias FailureCompletionHandler = (Error) -> Void
    
    @discardableResult
    func success(completionHandler: @escaping SuccessCompletionHandler) -> Self {
        return self.resume { (completion) -> Void in
            if case .success(let object) = completion {
                completionHandler(object)
            }
        }
    }
    
    @discardableResult
    func failure(completionHandler: @escaping FailureCompletionHandler) -> Self {
        return self.resume { (completion) -> Void in
            if case .failure(let error) = completion {
                completionHandler(error)
            }
        }
    }
}
