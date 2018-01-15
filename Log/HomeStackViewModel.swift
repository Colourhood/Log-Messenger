//
//  HomeViewModel.swift
//  Log
//
//  Created by Andrei Villasana on 1/9/18.
//  Copyright © 2018 Andrei Villasana. All rights reserved.
//

import Foundation

class HomeStackViewModel {
    var msArr: [MessageStack] = []

}

extension HomeStackViewModel {

    func add(stack: MessageStack) {
        msArr.append(stack)
    }

}
