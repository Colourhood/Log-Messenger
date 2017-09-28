//
//  ConvertImage.swift
//  Log
//
//  Created by Andrei Villasana on 9/18/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct ConvertImage {

    static func convertUIImageToPNGData(image: UIImage) -> Data? {
        if let imageData = UIImagePNGRepresentation(image) {
            return imageData;
        }
        return nil
    }

    static func convertUIImageToJPEGData(image: UIImage) -> Data? {
        if let imageData = UIImageJPEGRepresentation(image, 0.5) {
            return imageData;
        }
        return nil;
    }

}
