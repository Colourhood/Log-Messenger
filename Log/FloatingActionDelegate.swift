//
//  FloatingActionDelegate.swift
//  Log
//
//  Created by Andrei Villasana on 11/12/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

protocol FloatingActionDelegate: class {

    func floactingActionWillOpen()
    func floatingActionDidOpen()
    func floatingActionWillClose()
    func floatingActionDidClose()

}
