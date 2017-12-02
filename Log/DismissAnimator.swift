//
//  DismissAnimator.swift
//  Log
//
//  Created by Andrei Villasana on 12/1/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.transform = CGAffineTransform(translationX: fromVC.view.frame.width, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}
