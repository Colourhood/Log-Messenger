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

    @IBOutlet weak var dot1: UIView?
    @IBOutlet weak var dot2: UIView?
    @IBOutlet weak var dot3: UIView?

    override func awakeFromNib() {
        messageView.layer.cornerRadius = messageView.frame.width/12

        if let dot1 = dot1, let dot2 = dot2, let dot3 = dot3 {
            messageView.layer.cornerRadius = messageView.frame.width/5
            let circleRadius = dot1.frame.height/2
            dot1.layer.cornerRadius = circleRadius
            dot2.layer.cornerRadius = circleRadius
            dot3.layer.cornerRadius = circleRadius
        }
    }

}

extension MessageTableViewCell {
    func animatePop() {
        alpha = 0
        messageView.transform = CGAffineTransform(scaleX: 0.04, y: 0.04)
        userImage.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.messageView.transform = CGAffineTransform.identity
            self.userImage.transform = CGAffineTransform.identity
        })
    }

    func animateTyping() {
        guard let dot1 = dot1, let dot2 = dot2, let dot3 = dot3 else { return }

        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [.repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                dot1.transform = CGAffineTransform(translationX: dot1.bounds.origin.x, y: dot1.bounds.origin.y-3.5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                dot1.transform = CGAffineTransform(translationX: dot1.bounds.origin.x, y: dot1.bounds.origin.y)
                dot2.transform = CGAffineTransform(translationX: dot2.bounds.origin.x, y: dot2.bounds.origin.y-3.5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                dot2.transform = CGAffineTransform(translationX: dot2.bounds.origin.x, y: dot2.bounds.origin.y)
                dot3.transform = CGAffineTransform(translationX: dot3.bounds.origin.x, y: dot3.bounds.origin.y-3.5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                dot3.transform = CGAffineTransform(translationX: dot3.bounds.origin.x, y: dot3.bounds.origin.y)
            })
        })
    }
}
