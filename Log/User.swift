//
//  User.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct User {
    var email: String
    var firstName: String
    var picture: UIImage

    init(email: String, firstName: String, picture: UIImage) {
        self.email = email
        self.firstName = firstName
        self.picture = picture
    }

}
