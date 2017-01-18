//
//  TextQueryRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 13/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public enum TextQueryType {
    case one(String)
    case array([String])
}

extension TextQueryType {
    var JSON: AnyObject {
        switch self {
        case .one(let object):
            return object as AnyObject
        case .array(let object):
            return object as AnyObject
        }
    }
}

extension TextQueryType {
    func jsonObject() -> AnyObject {
        switch self {
        case .one(let object):
            return object as AnyObject
        case .array(let object):
            return object as AnyObject
        }
    }
}

public protocol TextQueryRequestType : QueryRequest {
    var query: TextQueryType { get }
}

open class TextQueryRequest: TextQueryRequestType, PrivateRequest, QueryContainer {
    internal var started: Bool = false

    //private properties
    
    weak var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? = .none
    
    let method: String = "query"
    var dataTask: URLSessionDataTask? = nil
    
    // public properties
    
    public typealias ResponseType = QueryResponse
    
    open let credentials: Credentials
    open let session: URLSession
    
    open var queryParameters: QueryParameters
    
    open let query: TextQueryType
    
    open let language: Language
    
    public init(query: TextQueryType, credentials: Credentials, queryParameters: QueryParameters, session: URLSession, language: Language) {
        self.query = query
        self.credentials = credentials
        self.session = session
        self.queryParameters = queryParameters
        self.language = language
    }
    
    public convenience init(query: String, credentials: Credentials, queryParameters: QueryParameters, session: URLSession, language: Language) {
        self.init(query: .one(query), credentials: credentials, queryParameters: queryParameters, session: session, language: language)
    }
    
    public convenience init(query: [String], credentials: Credentials, queryParameters: QueryParameters, session: URLSession, language: Language) {
        self.init(query: .array(query), credentials: credentials, queryParameters: queryParameters, session: session, language: language)
    }
    
    func runRequest() throws -> URLSessionDataTask {
        let callbacksContainer = CallbacksContainer<RequestCompletion<ResponseType>>()
        
        self.callbacks = callbacksContainer
        
        var request = self.request
        
        request.httpBody = try self.jsonRequestParameters(["query": query.jsonObject()])
        
        let dataTask = self.session.dataTask(with: request) { (data, response, error) in
            callbacksContainer.resolve(self.handleQueryResponse(data, response, error))
        }
        
        dataTask.resume()
        
        return dataTask
    }
    
    fileprivate func run(_ completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void) {
        self.privateResume(completionHandler)
    }
    
    open func resume(completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void) -> Self {
        // TODO: Replace run-function with the following call.
//        (self as TextQueryRequest).privateResume(completionHandler)
        self.run(completionHandler)
        return self
    }
    
    open func cancel() {
        let cancelError = NSError(code: .requestUserCancelled, message: "Request user cancelled.")
        
        callbacks?.resolve(.failure(cancelError))
        
        dataTask?.cancel()
    }
}
