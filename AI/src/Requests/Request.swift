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
    
    typealias ResponseType
    
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

//public enum Query {
//    case Text(String)
//    case TextArray([String])
//}
//
//public protocol TextQueryRequest: QueryRequest {
//    var query: Query { get }
//}
//
//public class TextQuery: Request, TextQueryRequest {
////    public typealias ResponseType = QueryResponse
//    
////    public func qwe() {
////        
////    }
//    
//    public let query: Query
//    
//    private var callbacks: CallbacksContainer<RequestCompletion<TextQuery.ResponseType>>? = .None
//
//    private var dataTask: NSURLSessionDataTask? = .None
//    
//    init(query: Query) {
//        self.query = query
//    }
//    
////    private var query: String
////    
////    init(query: String) {
////        self.query = query
////    }
//    
//    public func resume(completionHandler: (RequestCompletion<TextQuery.ResponseType>) -> Void) -> Self {
//        runRequestIfNeeded();
//        
//        callbacks?.put({ (completion) -> Void in
//            completionHandler(completion)
//        })
//
//        return self
//    }
//    
//    private func runRequestIfNeeded() {
//        if dataTask == nil {
//            let callbacksContainer = CallbacksContainer<RequestCompletion<ResponseType>>()
//
//            callbacks = callbacksContainer
//            
//            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.api.ai/v1/query?v=20150910")!)
//            
//            request.addValue("Bearer b316a120a0ab4383980746032c21c4f5", forHTTPHeaderField: "Authorization");
//            request.addValue("4c91a8e5-275f-4bf0-8f94-befa78ef92cd", forHTTPHeaderField: "ocp-apim-subscription-key")
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            request.HTTPMethod = "POST"
//            
//            let parameters = [
//                "query": query,
//                "lang": "en"
//            ]
//            
//            do {
//                let body = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions(rawValue: 0))
//                request.HTTPBody = body
//                
//                dataTask = NSURLSession.sharedSession().dataTaskWithRequest(
//                    request) { (data, response, error) -> Void in
//                        let response = handle(data, response, error).next(serializeJSON).next(validateObject).next(serializeObject)
//                        
//                        callbacksContainer.resolve(response.toRequestCompletion())
//                }
//                dataTask?.resume()
//            } catch let error as NSError {
//                callbacksContainer.resolve(.Failure(error))
//            }
//        }
//    }
//    
//    public func cancel() {
//        dataTask?.cancel()
//    }
//}