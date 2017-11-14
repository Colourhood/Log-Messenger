//
//  FloatingActionWindow.swift
//  Log
//
//  Created by Andrei Villasana on 11/12/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class FloatingActionWindow: UIWindow {

    let rootView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareWindow()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareWindow()
    }

    func prepareWindow() {
        rootViewController = rootView
        makeKeyAndVisible()
        addSubview(FloatingActionView())
    }

}
