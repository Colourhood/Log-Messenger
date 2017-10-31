//
//  FromRightSegue.swift
//  Log
//
//  Created by Andrei Villasana on 10/30/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import QuartzCore

class FromRightSegue: UIStoryboardSegue {

    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController?.view.layer.add(transition, forKey: kCATransition)
        src.navigationController?.pushViewController(dst, animated: false)
    }
}
