//
//  ProfileImageView.swift
//  Log
//
//  Created by Andrei Villasana on 11/19/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }

}
