//
//  DraggableRightViewController.swift
//  Log
//
//  Created by Andrei Villasana on 1/13/18.
//  Copyright © 2018 Andrei Villasana. All rights reserved.
//

import Foundation

class DraggableRightViewController: UIViewController {

    private lazy var dismissTransitionDelegate = DismissManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDraggableGesture()
    }

    func setUpDraggableGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (MessageViewController.handleGesture))
        self.view.addGestureRecognizer(panGestureRecognizer)
        transitioningDelegate = dismissTransitionDelegate
    }

    @objc func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            if translation.x > 0 {
                view.frame.origin = CGPoint(x: translation.x, y: 0)
            }
        case .ended:
            if translation.x > view.frame.size.width/3*2 || gesture.velocity(in: view).x > 100 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.view.frame.origin = CGPoint(x: 0, y: 0)
                })
            }
        case .cancelled:
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.view.frame.origin = CGPoint(x: 0, y: 0)
            })
        default:
            break
        }
    }

}
