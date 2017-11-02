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
        animation();
    }

    func animation() {
        let sourceView = self.source;
        let destinationView = self.destination

        let containerView = sourceView.view.superview;

        destinationView.view.transform = CGAffineTransform(translationX: sourceView.view.frame.width, y: 0);

        containerView?.addSubview(destinationView.view);

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        destinationView.view.transform = CGAffineTransform(translationX: 0, y: 0);
                       },
                       completion: { _ in
                        sourceView.present(destinationView, animated: false, completion: nil);
                       }
        );
    }
}

class UnwindSegueFromRight: UIStoryboardSegue {

    override func perform() {
        unwindAnimation();
    }

    func unwindAnimation() {
        let sourceView = self.source;
        let destinationView = self.destination

        sourceView.view.superview?.insertSubview(destinationView.view, at: 0);

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        sourceView.view.transform = CGAffineTransform(translationX: sourceView.view.frame.width, y: 0);
                       },
                       completion: { _ in
                        sourceView.dismiss(animated: false, completion: nil);
                       }
        );
    }

}
