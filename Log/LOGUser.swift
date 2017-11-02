//
//  User.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import UIKit

struct LOGUser {

    private var email: String?
    private var firstName: String?
    private var lastName: String?
    private var picture: UIImage?

    init(email: String?, firstName: String?, lastName: String?, picture: UIImage?) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
    }

    func getEmail() -> String? {
        return email
    }

    func getFirstName() -> String? {
        return firstName
    }

    func getFullName() -> String? {
        let fullName: String? = "\(String(describing: firstName)) \(String(describing: lastName))"
        return fullName
    }

    func getPicture() -> UIImage? {
        return picture
    }

}
