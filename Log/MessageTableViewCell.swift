//
//  MessageTableViewCell.swift
//  Log
//
//  Created by Andrei Villasana on 11/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var userImage: ProfileImageView!

    override func awakeFromNib() {
        messageView.layer.cornerRadius = messageView.frame.width/20
        animatePop()
    }

}

extension MessageTableViewCell {

    func animatePop() {
        messageView.transform = CGAffineTransform(scaleX: 0.04, y: 0.04)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.messageView.transform = CGAffineTransform.identity
        })
    }

}
