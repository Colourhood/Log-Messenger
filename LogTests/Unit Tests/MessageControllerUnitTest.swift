//
//  MessageControllerUnitTest.swift
//  LogTests
//
//  Created by Andrei Villasana on 11/6/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import XCTest
@testable import Log
import CoreData

class MessageControllerUnitTest: XCTestCase {

    var mockManageObjectContext: NSManagedObjectContext?
    var userEntity: UserCoreData?

    func setupInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding persistent store failed")
        }
        let managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        return managedObjectContext
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        mockManageObjectContext = setupInMemoryManagedObjectContext()
        userEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: mockManageObjectContext!) as? UserCoreData

        userEntity?.email = "andreicrimson@gmail.com"
        userEntity?.firstName = "Andrei"
        userEntity?.lastName = "Villasana"
    }

    func testUserCoreData() {
        XCTAssertEqual(userEntity?.email, "andreicrimson@gmail.com")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
