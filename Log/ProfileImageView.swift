//
//  ProfileImageView.swift
//  Log
//
//  Created by Andrei Villasana on 11/19/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }

}
