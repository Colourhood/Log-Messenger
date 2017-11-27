//
//  HomeTableViewCell.swift
//  Log
//
//  Created by Andrei Villasana on 11/27/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var friendPicture: ProfileImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var mostRecentMessageFromConversation: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
