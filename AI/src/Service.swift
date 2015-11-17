//
//  Service.swift
//  AI
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public protocol BaseService {
    var credentials: Credentials { get }
    var URLSession: NSURLSession { get }
}

public protocol QueryService: BaseService {
    var defaultQueryParameters: QueryParameters { get set }
    var language: Language { get }
}

public extension QueryService {
    func TextRequest(query: TextQueryType) -> TextQueryRequest {
        return TextQueryRequest(query: query, credentials: credentials, queryParameters: defaultQueryParameters, session: URLSession, language: language)
    }
    
    func TextRequest(query: String) -> TextQueryRequest {
        return TextRequest(.One(query))
    }
    
    func TextRequest(query: [String]) -> TextQueryRequest {
        return TextRequest(.Array(query))
    }
}

public class Service: QueryService {
    public var credentials: Credentials
    public var URLSession: NSURLSession
    
    public let language: Language
    
    public var defaultQueryParameters: QueryParameters
    
    init(credentials: Credentials, URLSession: NSURLSession, defaultQueryParameters: QueryParameters, language: Language) {
        self.URLSession = URLSession
        self.credentials = credentials
        
        self.defaultQueryParameters = defaultQueryParameters
        
        self.language = language
    }
}