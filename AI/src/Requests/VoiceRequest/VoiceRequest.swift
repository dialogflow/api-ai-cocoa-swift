//
//  VoiceRequest.swift
//  AI
//
//  Created by Kuragin Dmitriy on 16/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

class ReferenceArray<T> {
    private var array: [T] = []
    
    func push(object: T) {
        array.append(object)
    }
    
    var objects: [T] {
        return array
    }
}

private func capture(object: AnyObject) {
    
}

public typealias LevelChangedHandler = (Float) -> Void

public protocol VoiceQueryRequestType: QueryRequest {
    var useVAD: Bool { get }
    
    func stopListening()
    
    func level(levelChangedHandler: LevelChangedHandler) -> Self
}

public class VoiceQueryRequest: VoiceQueryRequestType, PrivateRequest, BoundaryContainer, QueryContainer {
    public var useVAD: Bool = true
    
    typealias Generator = RandomBoundaryGenerator
    let boundary: String = Generator.generate()
    
    let method = "query"
    var onceToken: dispatch_once_t = 0
    var dataTask: NSURLSessionDataTask? = .None
    
    private weak var stream: BufferedOutputStream? = .None
    private weak var audioRecorder: QueueAudioRecorder? = .None
    private weak var levelChangedCallbacks: ReferenceArray<LevelChangedHandler>? = .None
    
    var callbacks: CallbacksContainer<RequestCompletion<ResponseType>>? = .None
    
    public typealias ResponseType = QueryResponse
    
    public let queryParameters: QueryParameters
    public let language: Language
    
    public let credentials: Credentials
    public let session: NSURLSession
    
    public init(useVAD: Bool, credentials: Credentials, queryParameters: QueryParameters, session: NSURLSession, language: Language) {
        self.credentials = credentials
        self.session = session
        self.queryParameters = queryParameters
        self.language = language
    }
    
    func runRequest() throws -> NSURLSessionDataTask {
        let callbacksContainer = CallbacksContainer<RequestCompletion<ResponseType>>()
        
        let levelChangedCallbacks = ReferenceArray<LevelChangedHandler>()
        self.levelChangedCallbacks = levelChangedCallbacks
        
        self.callbacks = callbacksContainer
        
        let request = self.request
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        
        let (readStream, writeStream) = BufferedOutputStream.boundStreamsWithBufferSize()
        
        request.HTTPBodyStream = readStream
        
        let bufferedOutputStream = BufferedOutputStream(stream: writeStream)
        
        self.stream = bufferedOutputStream
        
        var vad: CrossZeroRateVAD? = .None
        
        if (self.useVAD) {
            vad = CrossZeroRateVAD()
        }
        
        let recorder = QueueAudioRecorder {[weak self] (data, size) -> Void in
            bufferedOutputStream.append(data, size)
            
            if let vad = vad {
                let state = vad.process(data, len: size)
                if case .EndOfSpeech = state {
                    self?.stopListening()
                }
            }
        }
        
        callbacksContainer.onResolve(recorder.stop)
        
        self.audioRecorder = recorder
        
        recorder.handleFailedCompletion { (error) -> Void in
            callbacksContainer.resolve(.Failure(error))
        }
        
        recorder.handleLevelChanged { (level) -> Void in
            for object in levelChangedCallbacks.objects {
                object(level)
            }
        }
        
        bufferedOutputStream.open()
        
        let parameters = try self.jsonRequestParameters()
        
        bufferedOutputStream.append(
            "--\(boundary)\r\n" +
            "Content-Disposition: form-data; name=\"request\"; filename=\"request.json\"\r\n" +
            "Content-Type: application/json\r\n\r\n"
        )
        
        bufferedOutputStream.appendData(parameters)
        
        bufferedOutputStream.append(
            "\r\n--\(boundary)\r\n" +
            "Content-Disposition: form-data; name=\"voiceData\"; filename=\"qwe.wav\"\r\n" +
            "Content-Type: audio/wav\r\n\r\n"
        )
        
        let dataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            capture(recorder)
            callbacksContainer.resolve(self.handleQueryResponse(data, response, error))
        })
        
        callbacksContainer.onResolve(dataTask.cancel)
        
        dataTask.resume()
        
        recorder.start()
        
        return dataTask
    }
    
    public func stopListening() {
        audioRecorder?.stop()
        stream?.append("\r\n--\(boundary)--\r\n")
        stream?.close()
    }
    
    public func level(levelChangedHandler: LevelChangedHandler) -> Self {
        levelChangedCallbacks?.push(levelChangedHandler)
        
        return self
    }
    
    private func run(completionHandler: (RequestCompletion<ResponseType>) -> Void) {
        self.privateResume(completionHandler)
    }
    
    public func resume(completionHandler: (RequestCompletion<ResponseType>) -> Void) -> Self {
        // TODO: Replace run-function with the following call.
//        (self as VoiceQueryRequest).privateResume(completionHandler)
        self.run(completionHandler)
        return self
    }
    
    public func cancel() {
        dataTask?.cancel()
    }
}