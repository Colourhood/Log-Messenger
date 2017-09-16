//
//  LogTests.swift
//  LogTests
//
//  Created by Andrei Villasana on 9/15/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import XCTest
@testable import Log

class LogTests: XCTestCase {
    
    var username: String?;
    var password: String?;
    
    override func setUp() {
        super.setUp();
        self.username = "andreicrimson@gmail.com";
        self.password = "password";
    }
    
    override func tearDown() {
        super.tearDown();
        self.username = nil;
        self.password = nil;
    }
    
    func testLogInEndpoint() {
        let expect = expectation(description: "Login in succeeded");
        
        SignInController.handleLoginSignUpRequest(url: "/user/login", email: self.username, password: self.username) { (json) in
            if let userkey = json["username"] as? String {
                if (userkey == self.username) {
                    expect.fulfill();
                }
            }
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print("Error: Test timed out");
        };
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
