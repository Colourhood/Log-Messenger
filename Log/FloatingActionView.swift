//
//  FloatingActionButton.swift
//  Log
//
//  Created by Andrei Villasana on 11/10/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import Lottie

class FloatingActionView: UIView {

    var contentView: UIView!
    @IBOutlet weak var floatingActionButton: UIButton!
    @IBAction func actionButton() {
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func loadFromNib<T: UIView>() -> T {
        guard let view = UINib(nibName: "FloatingActionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? T else { fatalError("Error loading from nib") }
        return view
    }

    private func xibSetup() {
        contentView = loadFromNib()
        designSetup()
        addSubview(contentView)
    }

    private func designSetup() {
        let screenBounds = UIScreen.main.bounds
        let contentBounds = contentView.bounds
        let offset = CGFloat(10)
        frame = CGRect(x: screenBounds.width-contentBounds.width-offset,
                       y: (screenBounds.height/2),
                       width: contentBounds.width,
                       height: contentBounds.height)
        layer.masksToBounds = true
        contentView.addSubview(lottieView())
    }

    private func lottieView() -> UIView {
        let animatedView = LOTAnimationView(name: "GreyCircleAnimation")
        animatedView.frame = bounds
        animatedView.loopAnimation = true
        animatedView.play()
        return animatedView
    }

}
