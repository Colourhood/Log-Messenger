//
//  DismissManager.swift
//  Log
//
//  Created by Andrei Villasana on 12/1/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class DismissManager: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
}
