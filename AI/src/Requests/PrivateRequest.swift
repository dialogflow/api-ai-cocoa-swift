//
//  PrivateRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 13/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

let kBaseURLString = "https://api.api.ai/v1"

protocol QueryContainer {
    func query() -> String
}

protocol PrivateRequest: class {
    var method: String { get }
    var onceToken: dispatch_once_t { get set }
    var dataTask: NSURLSessionDataTask? { get set }
    
    var request: NSMutableURLRequest { get }
    
    associatedtype ResponseType
    var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? { get set }
    
    func runRequest() throws -> NSURLSessionDataTask
    
    func privateResume(completionHandler: (RequestCompletion<ResponseType>) -> Void);
}

extension PrivateRequest {
    func privateResume(completionHandler: (RequestCompletion<ResponseType>) -> Void) {
        var token = onceToken
        dispatch_once(&token) {[unowned self] () -> Void in
            do {
                try self.dataTask = self.runRequest()
            } catch let error as NSError {
                self.callbacks?.resolve(.Failure(error))
            }
        }
        
        onceToken = token
        
        callbacks?.put(completionHandler)
    }
}

extension PrivateRequest where Self: Request {
    var request: NSMutableURLRequest {
        let request = NSMutableURLRequest()
        
        if let baseURL = NSURL(string: kBaseURLString) {
            let URLComponents = NSURLComponents(URL: baseURL.URLByAppendingPathComponent(self.method), resolvingAgainstBaseURL: false)
            if let URLComponents = URLComponents {
                if let queryContainer = self as? QueryContainer {
                    URLComponents.query = queryContainer.query()
                }
                
                request.URL = URLComponents.URL
            }
        }

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.HTTPMethod = "POST"
        
        request.authenticate(credentials)
        
        return request
    }
}

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension PrivateRequest where Self: QueryRequest {
    func jsonRequestParameters(additionalParameters: [String:AnyObject] = [String:AnyObject]()) throws -> NSData {
        var parameters = queryParameters.jsonObject()
        parameters["lang"] = language.stringValue
        
        parameters += additionalParameters
        
        
        let jsonBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions(rawValue: 0))
        
        return jsonBody
    }
}

extension PrivateRequest where Self: QueryRequest {
    func handleQueryResponse(data: NSData?, _ response: NSURLResponse?, _ error: NSError?) -> RequestCompletion<QueryResponse> {
        let response = handle(data, response, error).next(serializeJSON).next(validateObject).next(serializeObject)
        
        switch response {
        case .Success(let object):
            return .Success(object)
        case .Failure(let error):
            let nsError = error.asNSError()
            return .Failure(nsError)
        }
    }
}

protocol BoundaryContainer {
    associatedtype Generator: BoundaryGenerator
    var boundary: String { get }
}

protocol BoundaryGenerator {
    static func generate() -> String
}

class RandomBoundaryGenerator: BoundaryGenerator {
    static func generate() -> String {
        return String(format: "Boundary+%08X%08X", arc4random(), arc4random())
    }
}