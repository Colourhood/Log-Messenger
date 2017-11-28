//
//  Debouncer.swift
//  Log
//
//  Created by Andrei Villasana on 11/27/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//  Credit to - https://github.com/webadnan/swift-debouncer

import Foundation

class Debouncer: NSObject {
    var callback: (() -> Void)
    var delay: Double
    weak var timer: Timer?

    init(delay: Double, callback: @escaping (() -> Void)) {
        self.delay = delay
        self.callback = callback
    }

    func call() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
    }

    @objc func fireNow() {
        self.callback()
    }
}
