//
//  SegueFromRight.swift
//  Log
//
//  Created by Andrei Villasana on 11/1/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class SegueFromRight: UIStoryboardSegue {

    override func perform() {
        animation()
    }

    private func animation() {
        let sourceView = self.source
        let destinationView = self.destination
        let containerView = sourceView.view.superview

        destinationView.view.transform = CGAffineTransform(translationX: sourceView.view.frame.width, y: 0)

        containerView?.addSubview(destinationView.view)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            destinationView.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            sourceView.present(destinationView, animated: false, completion: nil)
        })
    }

}
