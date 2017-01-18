//
//  Completion.swift
//  AI
//
//  Created by Kuragin Dmitriy on 10/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation


typealias CompletionError = Error

enum Completion<A> {
    case success(A)
    case failure(CompletionError)
}

extension Completion {
    func next<B>(_ f: (A) -> Completion<B>) -> Completion<B>{
        switch self {
        case .success(let x):
            return f(x)
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Completion {
    func next(_ error: CompletionError?) -> Completion<A> {
        switch self {
        case .success(let x):
            if let error = error {
                return .failure(error)
            } else {
                return .success(x)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

struct CompletionStringError: Error {
    let errorMessage: String
}
