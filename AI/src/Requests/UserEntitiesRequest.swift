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
    
    public init(value: String, synonyms: [String]) {
        self.value = value
        self.synonyms = synonyms
    }
}

extension UserEntityEntry {
    func jsonObject() -> [String: AnyObject] {
        return [
            "value": value as AnyObject,
            "synonyms": synonyms as AnyObject
        ]
    }
}

public struct UserEntity {
    public var sessionId: String? = SessionStorage.defaultSessionIdentifier
    public var name: String
    public var entries: [UserEntityEntry]
    public var extend: Bool = false
    
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
    func jsonObject() -> [String: Any] {
        var object: [String: Any] = [
            "name": name as Any,
            "entries": entries.map { (entry) -> [String: Any] in
                entry.jsonObject()
            }
        ]
        
        if let sessionId = sessionId {
            object["sessionId"] = sessionId
        }
        
        object["extend"] = extend
        
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
    var started: Bool = false

    weak var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? = .none
    
    let method: String = "userEntities"
    var dataTask: URLSessionDataTask? = nil
    
    public typealias ResponseType = UserEntitiesResponse
    
    public let credentials: Credentials
    public let session: URLSession
    
    fileprivate let entities: [UserEntity]
    
    init(credentials: Credentials, entities: [UserEntity], session: URLSession) {
        self.credentials = credentials
        self.session = session
        self.entities = entities
    }
    
    fileprivate func serializeRequest() throws -> Data {
        let requestBody = self.entities.map { (entity) -> [String: Any] in
            entity.jsonObject()
        }
        
        return try JSONSerialization.data(withJSONObject: requestBody, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    func runRequest() throws -> URLSessionDataTask {
        let callbacksContainer = CallbacksContainer<RequestCompletion<ResponseType>>()
        
        self.callbacks = callbacksContainer
        
        var request = self.request
        
        request.httpBody = try self.serializeRequest()
        
        let dataTask = self.session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            let response = handle(data, response, error).next(serializeJSON).next(validateObject).next(userEntitiesResponseSerialize)
            
            switch response {
            case .success(let object):
                callbacksContainer.resolve(.success(object))
            case .failure(let error):
                callbacksContainer.resolve(.failure(error))
            }
        })
        
        dataTask.resume()
        
        return dataTask
    }
    
    fileprivate func run(_ completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void) {
        self.privateResume(completionHandler)
    }
    
    @discardableResult
    public func resume(completionHandler: @escaping (RequestCompletion<ResponseType>) -> Void) -> Self {
        // TODO: Replace run-function with the following call.
        //        (self as TextQueryRequest).privateResume(completionHandler)
        self.run(completionHandler)
        return self
    }
    
    public func cancel() {
        let cancelError = NSError(code: .requestUserCancelled, message: "Request user cancelled.")
        
        callbacks?.resolve(.failure(cancelError))
        
        dataTask?.cancel()
    }
}

func userEntitiesResponseSerialize(_ object: [String: Any]) -> Completion<UserEntitiesResponse> {
    guard let statusObject = object["status"] else {
        return .failure(SerializeError.missingKey("status"))
    }
    
    guard let status = statusObject as? [String: AnyObject] else {
        return .failure(SerializeError.typeMismatch("status"))
    }
    
    guard let code = status["code"] as? Int else {
        return .failure(SerializeError.missingKey("code"))
    }
    
    guard let errorType = status["errorType"] as? String else {
        return .failure(SerializeError.missingKey("errorType"))
    }
    
    return .success(UserEntitiesResponse(code: code, errorType: errorType))
}
