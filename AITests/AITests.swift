//
//  AITests.swift
//  AITests
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import XCTest
//import AI
//import AI
import AVFoundation
@testable import AI


class AITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func t1estExample() {
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error")
        }
        
        let expectation = expectationWithDescription("q23")
        
        AI.configure("3485a96fb27744db83e78b8c4bc9e7b7", "cb9693af-85ce-4fbf-844a-5563722fc27f")
        
//        AI.sharedService.VoiceRequest().success { (response) -> Void in
//            print("")
//        }.failure { (error) -> Void in
//            print("")
//        }
        
        AI.sharedService.TextRequest("Hello").success { (response) -> Void in
            
        }.failure { (error) -> Void in
            
        }
        
//        let request = VoiceQueryRequest(
//            useVAD: true,
//            credentials: Credentials("3485a96fb27744db83e78b8c4bc9e7b7", "cb9693af-85ce-4fbf-844a-5563722fc27f"),
//            queryParameters: QueryParameters(),
//            session: NSURLSession.sharedSession(),
//            language: .English
//        ).success { (response) -> Void in
//            print("")
//        }.failure { (error) -> Void in
//            print("")
//        }
//        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
////            request.stopListening()
//        }
        
        
        
//        let recorder = QueueAudioRecorder { (data, size) -> Void in
//            print("1")
//        }
//        
//        recorder.start()
        
//        AI.configure("3485a96fb27744db83e78b8c4bc9e7b7", "cb9693af-85ce-4fbf-844a-5563722fc27f")
////        AI.configure("b316a120a0ab4383980746032c21c4f5", "4c91a8e5-275f-4bf0-8f94-befa78ef92cd")
//        
////        let query = "Hello"
//        let query = "weather in london"
//        
//        AI.sharedService.TextRequest(query).success { (response) -> Void in
//            print("")
//        }.failure { (error) -> Void in
//            print("")
//        }
        
        waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            
        }

//        let expectation = expectationWithDescription("q23")
//        
//        let parameters = QueryParameters()
//        
//        let request = TextQueryRequest(query: .One("Hello"), credentials: Credentials("b316a120a0ab4383980746032c21c4f5", "4c91a8e5-275f-4bf0-8f94-befa78ef92cd"), queryParameters: parameters, session: NSURLSession.sharedSession())
//        
//        request.resume { (completion) -> Void in
//            print("")
//        }.success { (response) -> Void in
//            print("")
//        }.failure { (error) -> Void in
//            print("")
//        }
//        
//        waitForExpectationsWithTimeout(30.0) { (error) -> Void in
//
//        }
        
    }
    
    func testUserEntities() {
        let expectation = expectationWithDescription("123")
        
        AI.configure("09604c7f91ce4cd8a4ede55eb5340b9d", "4c91a8e5-275f-4bf0-8f94-befa78ef92cd")
        
        let entities = [
            UserEntity(name: "Application", entries: [
                    UserEntityEntry(value: "Firefox", synonyms: ["Firefox"]),
                    UserEntityEntry(value: "XCode", synonyms: ["XCode"]),
                    UserEntityEntry(value: "Sublime Text", synonyms: ["Sublime Text"])
                ])
        ]
        
        AI.sharedService.UserEntitiesUploadRequest(entities).success { (response) -> Void in
            print(response)
            
            expectation.fulfill()
        }.failure { (error) -> Void in
            print(error)
            expectation.fulfill()
            
        }
        
        waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            
        }
        
        
        let expectation2 = expectationWithDescription("1231")
        
        let query = "Open application Firefox"
        
        AI.sharedService.TextRequest(query).success { (response) -> Void in
            print(response)
            expectation2.fulfill()
        }.failure { (error) -> Void in
            print(error)
            expectation2.fulfill()
        }
        
        waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
