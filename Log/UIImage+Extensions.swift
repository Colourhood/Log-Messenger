//
//  ConvertImage.swift
//  Log
//
//  Created by Andrei Villasana on 9/18/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

extension UIImage {

    func dataJPEG() -> Data? {
        let data = UIImageJPEGRepresentation(self, 0.4)
        return data
    }
}
