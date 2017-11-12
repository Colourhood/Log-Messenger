//
//  FloatingActionButton.swift
//  Log
//
//  Created by Andrei Villasana on 11/10/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class FloatingActionView: UIView {

    @IBOutlet weak var mainView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        instanceFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instanceFromNib()
    }

    func instanceFromNib() {
        guard let view = UINib(nibName: "FloatingActionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView else { return }
        let viewBounds = view.bounds
        let screenBounds = UIScreen.main.bounds
        view.frame = CGRect(x: (screenBounds.width-viewBounds.width-10),
                            y: ((screenBounds.height-viewBounds.height)/2),
                            width: viewBounds.width,
                            height: viewBounds.height)
        view.alpha = 0.4
        view.layer.cornerRadius = viewBounds.width/2
        view.layer.masksToBounds = true
        mainView = view
        addSubview(mainView)
    }

}
