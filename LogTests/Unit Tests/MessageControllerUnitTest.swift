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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        mockManageObjectContext = setupInMemoryManagedObjectContext()
        userEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: mockManageObjectContext!) as? UserCoreData

        userEntity?.email = "andreicrimson@gmail.com"
        userEntity?.firstName = "Andrei"
        userEntity?.lastName = "Villasana"
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        mockManageObjectContext = nil
        userEntity = nil
    }

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

    func testGetMessages() {
        let friendEmail = "alex@gmail.com"

        getMessagesForFriend(friendEmail: friendEmail) { [weak self] (response) in
            guard let `self` = self else { return }
            if let messages = response["messages"] as? [AnyObject] {
                XCTAssert(true, "Messages key is not equal to nil")
                for messagePacket in messages {
                    if let messageDict = messagePacket as? [String: Any] {
                        let sentBy = messageDict["sent_by"] as? String
                        let message = messageDict["message"] as? String
                        let date = messageDict["created_at"] as? String

                        if sentBy == self.userEntity?.email {
                            XCTAssertEqual(sentBy, self.userEntity?.email)
                        } else if sentBy == friendEmail {
                            XCTAssertEqual(sentBy, friendEmail)
                        } else {
                            XCTFail("The server returned a user that is not part of the conversation \(sentBy!)")
                        }
                    } else {
                        XCTFail("There is a problem with the format for this message object")
                    }
                }
            } else {
                // XCTFail("There was an issue getting data from the server")
            }
        }
    }

    func getMessagesForFriend(friendEmail: String, completionHandler: @escaping ([String: Any]) -> Void) {
        if let userEmail = userEntity?.email {
            let request = LOGHTTP.get(url: "/user/messages/\(userEmail)/\(friendEmail)")

            request.responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    if let jsonDict = json as? [String: Any] {
                        XCTAssert(true, "Response returned a proper response")
                        completionHandler(jsonDict)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    XCTFail("There was an error with the response for the following endpoint: \(request)")
                }
            })
        } else {
            XCTFail("There was a problem with user core data")
        }
    }

}
