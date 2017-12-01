//
//  UserProfileTableViewCell.swift
//  Log
//
//  Created by Katherine Li on 10/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
