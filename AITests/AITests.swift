//
//  AITests.swift
//  AITests
//
//  Created by Kuragin Dmitriy on 11/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import XCTest
import AVFoundation
@testable import AI

class AITests: XCTestCase {
    
    lazy var ai = AI.sharedService
    
    override func setUp() {
        super.setUp()
        
        AI.configure("09604c7f91ce4cd8a4ede55eb5340b9d")
    }
    
    func testUserEntities() {
        let expectationUploadUserEntities = self.expectation(description: "Expect upload user entities.")
        
        let entities = [
            UserEntity(name: "Application", entries: [
                UserEntityEntry(value: "Firefox", synonyms: ["Firefox"]),
                UserEntityEntry(value: "XCode", synonyms: ["XCode"]),
                UserEntityEntry(value: "Sublime Text", synonyms: ["Sublime Text"])
            ])
        ]
        
        ai.userEntitiesUploadRequest(entities).success { (response) in
            expectationUploadUserEntities.fulfill()
        }.failure { (error) in
            XCTAssert(false, "Some error while uploading user entities. Detailed: \(error)")
            expectationUploadUserEntities.fulfill()
        }
        
        self.waitForExpectations(timeout: 30.0) { (error) in
            XCTAssertNil(error, "Some error while uploading user entities.")
        }
        
        let expectationQueryRequest = self.expectation(description: "Expect query request.")
        
        let query = "Open application XCode"
        
        ai.textRequest(query).success { (response) in
            let result = response.result
            
            XCTAssertEqual(result.resolvedQuery.lowercased(), query.lowercased(), "resolvedQuery should be equal query.")
            XCTAssertNotNil(result.action, "expecting nonnull action.")
            XCTAssertEqual(result.action!, "open_application", "expecting action 'open_application'.")
            
            XCTAssertNotNil(result.parameters, "expecting nonnull parameters.")
            let parameters = result.parameters!
            
            XCTAssertNotNil(parameters["application"] as? String, "expecting parameter 'application'.")
            XCTAssertEqual(parameters["application"] as! String, "XCode", "Unexpected parameter value.")
            
            expectationQueryRequest.fulfill()
        }.failure { (error) in
            XCTAssert(false, "Some error while sending query requests. Detailed: \(error)")
            expectationQueryRequest.fulfill()
        }
        
        self.waitForExpectations(timeout: 30.0) { (error) in
            XCTAssertNil(error, "Some error while sending query request.")
        }
    }
}
