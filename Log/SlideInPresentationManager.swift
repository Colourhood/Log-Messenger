//
//  SlideInPresentationManager.swift
//  Log
//
//  Created by Andrei Villasana on 11/28/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting)
        return presentationController
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return SlideInPresentationAnimator(isPresentation: false)
    }

}
