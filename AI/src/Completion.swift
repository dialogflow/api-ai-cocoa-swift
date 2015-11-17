//
//  Completion.swift
//  AI
//
//  Created by Kuragin Dmitriy on 10/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

protocol CompletionError {
    func asNSError() -> NSError
}

enum Completion<A> {
    case Success(A)
    case Failure(CompletionError)
}

extension Completion {
    func next<B>(f: A -> Completion<B>) -> Completion<B>{
        switch self {
        case .Success(let x):
            return f(x)
        case .Failure(let error):
            return .Failure(error)
        }
    }
}

extension Completion {
    func next(error: CompletionError?) -> Completion<A> {
        switch self {
        case .Success(let x):
            if let error = error {
                return .Failure(error)
            } else {
                return .Success(x)
            }
        case .Failure(let error):
            return .Failure(error)
        }
    }
}

extension NSError: CompletionError {
    func asNSError() -> NSError {
        return self
    }
}

extension String: CompletionError {
    func asNSError() -> NSError {
        return NSError(forErrorString: self)
    }
}