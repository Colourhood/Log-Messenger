//
//  MessageTableView.swift
//  Log
//
//  Created by Andrei Villasana on 12/27/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

enum MessageCellType: String {
    case userMessageCell, friendMessageCell,
         userPreviousMessageCell, friendPreviousMessageCell,
         typingMessageCell
}

class MessageTableView: UITableView {

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        UIAdjustments()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UIAdjustments()
    }

    private func UIAdjustments() {
        estimatedRowHeight = 50
        rowHeight = UITableViewAutomaticDimension
    }
}

extension MessageTableView {

    func scrollToBottom() {
        let rows = self.numberOfRows(inSection: 0)
        // This will guarantee rows - 1 >= 0
        if rows > 0 {
            let indexPath = IndexPath(row: rows-1, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

}
