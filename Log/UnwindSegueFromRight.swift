//
//  UnwindSegueFromRight.swift
//  Log
//
//  Created by Andrei Villasana on 12/15/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class UnwindSegueFromRight: UIStoryboardSegue {

    override func perform() {
        unwindAnimation()
    }

    func unwindAnimation() {
        let sourceView = self.source

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            sourceView.view.transform = CGAffineTransform(translationX: sourceView.view.frame.width, y: 0)
        }, completion: { _ in
            sourceView.dismiss(animated: false, completion: nil)
        })
    }

}
