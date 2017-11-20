//
//  MessageTableViewCell.swift
//  Log
//
//  Created by Andrei Villasana on 11/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var senderToReceiverLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var userImage: ProfileImageView!

    override func awakeFromNib() {
        self.messageView.layer.cornerRadius = 12
    }

}

extension MessageTableViewCell {
    func animate() {
        self.alpha = 0
        self.messageView.transform = CGAffineTransform(scaleX: 0.04, y: 0.04)
        self.userImage.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.messageView.transform = CGAffineTransform.identity
            self.userImage.transform = CGAffineTransform.identity
        })
    }
}
