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

    func animateBounce(delay: Double) {
        contentView.transform = CGAffineTransform(translationX: -contentView.frame.width, y: 0)

        UIView.animate(withDuration: 0.3, delay: TimeInterval(delay/3.5),
                       usingSpringWithDamping: 1, initialSpringVelocity: 0.5,
                       options: .curveEaseIn, animations: {
            self.contentView.transform = CGAffineTransform.identity
        })
    }

}
