//
//  TextQueryRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 13/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public enum TextQueryType {
    case One(String)
    case Array([String])
}

extension TextQueryType {
    var JSON: AnyObject {
        switch self {
        case .One(let object):
            return object
        case Array(let object):
            return object
        }
    }
}

extension TextQueryType {
    func jsonObject() -> AnyObject {
        switch self {
        case .One(let object):
            return object
        case Array(let object):
            return object
        }
    }
}

public protocol TextQueryRequestType : QueryRequest {
    var query: TextQueryType { get }
}

public class TextQueryRequest: TextQueryRequestType, PrivateRequest, QueryContainer {
    //private properties
    
    weak var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? = .None
    
    let method: String = "query"
    var onceToken: dispatch_once_t = 0
    var dataTask: NSURLSessionDataTask? = nil
    
    // public properties
    
    public typealias ResponseType = QueryResponse
    
    public let credentials: Credentials
    public let session: NSURLSession
    
    public var queryParameters: QueryParameters
    
    public let query: TextQueryType
    
    public let language: Language
    
    public init(query: TextQueryType, credentials: Credentials, queryParameters: QueryParameters, session: NSURLSession, language: Language) {
        self.query = query
        self.credentials = credentials
        self.session = session
        self.queryParameters = queryParameters
        self.language = language
    }
    
    public convenience init(query: String, credentials: Credentials, queryParameters: QueryParameters, session: NSURLSession, language: Language) {
        self.init(query: .One(query), credentials: credentials, queryParameters: queryParameters, session: session, language: language)
    }
    
    public convenience init(query: [String], credentials: Credentials, queryParameters: QueryParameters, session: NSURLSession, language: Language) {
        self.init(query: .Array(query), credentials: credentials, queryParameters: queryParameters, session: session, language: language)
    }
    
    func runRequest() throws -> NSURLSessionDataTask {
        let callbacksContainer = CallbacksContainer<RequestCompletion<ResponseType>>()
        
        self.callbacks = callbacksContainer
        
        let request = self.request
        
        request.HTTPBody = try self.jsonRequestParameters(["query": query.jsonObject()])
        
        let dataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            callbacksContainer.resolve(self.handleQueryResponse(data, response, error))
        })
        
        dataTask.resume()
        
        return dataTask
    }
    
    private func run(completionHandler: (RequestCompletion<ResponseType>) -> Void) {
        self.privateResume(completionHandler)
    }
    
    public func resume(completionHandler: (RequestCompletion<ResponseType>) -> Void) -> Self {
        // TODO: Replace run-function with the following call.
//        (self as TextQueryRequest).privateResume(completionHandler)
        self.run(completionHandler)
        return self
    }
    
    public func cancel() {
        let cancelError = NSError(code: .RequestUserCancelled, message: "Request user cancelled.")
        
        callbacks?.resolve(.Failure(cancelError))
        
        dataTask?.cancel()
    }
}