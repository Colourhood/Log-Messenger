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

    var userEmail: String?
    var password: String?

    override func setUp() {
        super.setUp()
        self.userEmail = "andreicrimson@gmail.com"
        self.password = "password"
    }

    override func tearDown() {
        super.tearDown()
        self.userEmail = nil
        self.password = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let promise = expectation(description: "Getting data from server")
        MessageController.getMessagesForFriend(friendEmail: "andreicrimson@gmail.com", completionHandler: { data in
            print("Received data: \(data)")
            promise.fulfill()
        })

        waitForExpectations(timeout: 5.0) { (error) in
            print("There was an error \(error!)")
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testExample()
        }
    }

}
