//
//  UserEntitiesRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 10/03/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import Foundation

public struct UserEntityEntry {
    public var value: String
    public var synonyms: [String]
}

extension UserEntityEntry {
    func jsonObject() -> [String: AnyObject] {
        return [
            "value": value,
            "synonyms": synonyms
        ]
    }
}

public struct UserEntity {
    public var sessionId: String? = SessionStorage.defaultSessionIdentifier
    public var name: String
    public var entries: [UserEntityEntry]
    
    public init(sessionId: String?, name: String, entries: [UserEntityEntry]) {
        self.sessionId = sessionId
        self.name = name
        self.entries = entries
    }
    
    public init(name: String, entries: [UserEntityEntry]) {
        self.name = name
        self.entries = entries
    }
}

extension UserEntity {
    func jsonObject() -> [String: AnyObject] {
        var object: [String: AnyObject] = [
            "name": name,
            "entries": entries.map { (entry) -> [String: AnyObject] in
                entry.jsonObject()
            }
        ]
        
        if let sessionId = sessionId {
            object["sessionId"] = sessionId
        }
        
        return object
    }
}

public struct UserEntitiesResponse {
    let code: Int
    let errorType: String?
}

public extension UserEntitiesResponse {
    var isSuccess: Bool {
        return code == 200
    }
}

public class UserEntitiesRequest: Request, PrivateRequest {
    weak var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? = .None
    
    let method: String = "userEntities"
    var onceToken: dispatch_once_t = 0
    var dataTask: NSURLSessionDataTask? = nil
    
    public typealias ResponseType = UserEntitiesResponse
    
    public let credentials: Credentials
    public let session: NSURLSession
    
    private let entities: [UserEntity]
    
    init(credentials: Credentials, entities: [UserEntity], session: NSURLSession) {
        self.credentials = credentials
        self.session = session
        self.entities = entities
    }
    
    private func serializeRequest() throws -> NSData {
        let requestBody = self.entities.map { (entity) -> [String: AnyObject] in
            entity.jsonObject()
        }
        
        return try NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions(rawValue: 0))
    }
    
    func runRequest() throws -> NSURLSessionDataTask {
        let callbacksContainer = CallbacksContainer<RequestCompletion<ResponseType>>()
        
        self.callbacks = callbacksContainer
        
        let request = self.request
        
        request.HTTPBody = try self.serializeRequest()
        
        let dataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let response = handle(data, response, error).next(serializeJSON).next(validateObject).next(userEntitiesResponseSerialize)
            
            switch response {
            case .Success(let object):
                callbacksContainer.resolve(.Success(object))
            case .Failure(let error):
                let nsError = error.asNSError()
                callbacksContainer.resolve(.Failure(nsError))
            }
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

func userEntitiesResponseSerialize(object: [String: AnyObject]) -> Completion<UserEntitiesResponse> {
    guard let statusObject = object["status"] else {
        return .Failure(SerializeError.MissingKey("status"))
    }
    
    guard let status = statusObject as? [String: AnyObject] else {
        return .Failure(SerializeError.TypeMismatch("status"))
    }
    
    guard let code = status["code"] as? Int else {
        return .Failure(SerializeError.MissingKey("code"))
    }
    
    guard let errorType = status["errorType"] as? String else {
        return .Failure(SerializeError.MissingKey("errorType"))
    }
    
    return .Success(UserEntitiesResponse(code: code, errorType: errorType))
}