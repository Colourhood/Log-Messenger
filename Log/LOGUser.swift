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
    private var picture: UIImage?

    init(email: String?, firstName: String?, picture: UIImage?) {
        self.email = email
        self.firstName = firstName
        self.picture = picture
    }

    func getEmail() -> String? {
        return email
    }

    func getFirstName() -> String? {
        return firstName
    }

    func getFullName() -> String? {
        if let firstName = firstName {
            return firstName
        } else {
            return "Inactive User"
        }
    }

    func getPicture() -> UIImage? {
        return picture
    }

}
