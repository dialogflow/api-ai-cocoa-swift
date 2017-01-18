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
    var URLSession: Foundation.URLSession { get }
}

public protocol QueryService: BaseService {
    var defaultQueryParameters: QueryParameters { get set }
    var language: Language { get }
}

public extension QueryService {
    func TextRequest(_ query: TextQueryType) -> TextQueryRequest {
        return TextQueryRequest(query: query, credentials: credentials, queryParameters: defaultQueryParameters, session: URLSession, language: language)
    }
    
    func TextRequest(_ query: String) -> TextQueryRequest {
        return TextRequest(.one(query))
    }
    
    func TextRequest(_ query: [String]) -> TextQueryRequest {
        return TextRequest(.array(query))
    }
}

public protocol UserEntitiesService: BaseService {

}

public extension UserEntitiesService {
    func UserEntitiesUploadRequest(_ entities: [UserEntity]) -> UserEntitiesRequest {
        return UserEntitiesRequest(credentials: credentials, entities: entities, session: URLSession)
    }
}

open class Service: BaseService, QueryService, UserEntitiesService {
    open var credentials: Credentials
    open var URLSession: Foundation.URLSession
    
    open let language: Language
    
    open var defaultQueryParameters: QueryParameters
    
    init(credentials: Credentials, URLSession: Foundation.URLSession, defaultQueryParameters: QueryParameters, language: Language) {
        self.URLSession = URLSession
        self.credentials = credentials
        
        self.defaultQueryParameters = defaultQueryParameters
        
        self.language = language
    }
}
