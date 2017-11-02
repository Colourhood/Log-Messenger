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

    var username: String?
    var password: String?

    override func setUp() {
        super.setUp()
        self.username = "andreicrimson@gmail.com"
        self.password = "password"
    }

    override func tearDown() {
        super.tearDown()
        self.username = nil
        self.password = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let promise = expectation(description: "These are equal to each other")

        let number = 1

        if (number == 1) {
            promise.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
