//
//  AI.swift
//  APII
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public struct AI {
    public static var language: Language = .english
    public static var credentials: Credentials? = .none {
        didSet {
            if let credentials = credentials {
                self.sharedService.credentials = credentials
            }
        }
    }
    
    public static var defaultQueryParameters: QueryParameters = QueryParameters()
    public static var session: URLSession = URLSession.shared
    
    public static func configure(_ credentials: Credentials) {
        self.credentials = credentials
    }
    
    public static func configure(_ clientAccessToken: String) {
        self.configure(Credentials(clientAccessToken))
    }
    
    public static func configure(clientAccessToken: String) {
        self.configure(clientAccessToken)
    }
}

extension AI {
    public static var sharedService: Service = AI.retrieveSharedService()
    
    fileprivate static func retrieveSharedService() -> Service {
        if let credentials = AI.credentials {
            return Service(credentials: credentials, session: session, defaultQueryParameters: defaultQueryParameters, language: language)
        } else {
            fatalError("Library should be configured. Use AI.configure methods.")
        }
    }
}

extension AI {

}
