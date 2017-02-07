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
    var started: Bool { get set }
    var dataTask: URLSessionDataTask? { get set }
    
    var request: URLRequest { get }
    
    associatedtype ResponseType
    var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? { get set }
    
    func runRequest() throws -> URLSessionDataTask
    
    func privateResume(_ completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void);
}

extension PrivateRequest {
    func privateResume(_ completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void) {
        if (!started) {
            started = true
            
            do {
                try self.dataTask = self.runRequest()
            } catch let error as NSError {
                self.callbacks?.resolve(.failure(error))
            }
        }
        
        callbacks?.put(completionHandler)
    }
}

extension PrivateRequest where Self: Request {
    var request: URLRequest {
        guard let baseURL = URL(string: kBaseURLString) else {
            fatalError("Could not get URL from URL string for base URL.")
        }
        
        var request = URLRequest(url: baseURL)
        
        let components = URLComponents(url: baseURL.appendingPathComponent(self.method), resolvingAgainstBaseURL: false)
        if var components = components {
            if let queryContainer = self as? QueryContainer {
                components.query = queryContainer.query()
            }
            
            request.url = components.url
        }

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        
        request.authenticate(credentials)
        
        return request
    }
}

func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension PrivateRequest where Self: QueryRequest {
    func jsonRequestParameters(_ additionalParameters: [String:AnyObject] = [String:AnyObject]()) throws -> Data {
        var parameters = queryParameters.jsonObject()
        parameters["lang"] = language.stringValue as AnyObject?
        
        parameters += additionalParameters
        
        
        let jsonBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0))
        
        return jsonBody
    }
}

extension PrivateRequest where Self: QueryRequest {
    func handleQueryResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> RequestCompletion<QueryResponse> {
        let response = handle(data, response, error)
            .next(serializeJSON)
            .next(validateObject)
            .next(serializeObject)
        
        switch response {
        case .success(let object):
            return .success(object)
        case .failure(let error):
            return .failure(error)
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
