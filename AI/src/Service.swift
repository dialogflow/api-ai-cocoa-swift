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
    var session: URLSession { get }
}

public protocol QueryService: BaseService {
    var defaultQueryParameters: QueryParameters { get set }
    var language: Language { get }
}

public extension QueryService {
    func textRequest(_ query: TextQueryType) -> TextQueryRequest {
        return TextQueryRequest(query: query, credentials: credentials, queryParameters: defaultQueryParameters, session: session, language: language)
    }
    
    func textRequest(_ query: String) -> TextQueryRequest {
        return textRequest(.one(query))
    }
    
    func textRequest(_ query: [TextQueryElement]) -> TextQueryRequest {
        return textRequest(.array(query))
    }
}

public protocol UserEntitiesService: BaseService {

}

public extension UserEntitiesService {
    func userEntitiesUploadRequest(_ entities: [UserEntity]) -> UserEntitiesRequest {
        return UserEntitiesRequest(credentials: credentials, entities: entities, session: session)
    }
}

public class Service: BaseService, QueryService, UserEntitiesService {
    public var credentials: Credentials
    public var session: URLSession
    
    public let language: Language
    
    public var defaultQueryParameters: QueryParameters
    
    init(credentials: Credentials, session: URLSession, defaultQueryParameters: QueryParameters, language: Language) {
        self.session = session
        self.credentials = credentials
        
        self.defaultQueryParameters = defaultQueryParameters
        
        self.language = language
    }
}
