//
//  AI.swift
//  APII
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public struct AI {
    public static var language: Language = .English
    public static var credentials: Credentials? = .None {
        didSet {
            if let credentials = credentials {
                self.sharedService.credentials = credentials
            }
        }
    }
    
    public static var defaultQueryParameters: QueryParameters = QueryParameters()
    public static var URLSession: NSURLSession = NSURLSession.sharedSession()
    
    public static func configure(credentials: Credentials) {
        self.credentials = credentials
    }
    
    public static func configure(clientAccessToken: String) {
        self.configure(Credentials(clientAccessToken))
    }
    
    public static func configure(clientAccessToken clientAccessToken: String) {
        self.configure(clientAccessToken)
    }
}

extension AI {
    public static var sharedService: Service {
        struct Static {
            static var token: dispatch_once_t = 0
            static var service: Service? = .None
        }
        
        dispatch_once(&Static.token) { () -> Void in
            if let credentials = AI.credentials {
                Static.service = Service(credentials: credentials, URLSession: URLSession, defaultQueryParameters: defaultQueryParameters, language: language)
            } else {
                fatalError("Library should be configured. Use AI.configure methods.")
            }
        }
        
        return Static.service!
    }
}

extension AI {

}