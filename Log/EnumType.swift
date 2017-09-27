//
//  FileTypes.swift
//  Log
//
//  Created by Andrei Villasana on 9/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct EnumType {
    
    static let allDirectories = [dir.Images];
    
    enum ext: String {
        case JSON = "json"
        case Text = "txt"
        case PDF = "pdf"
    }
    
    enum img: String {
        case PNG = "png"
        case JPEG = "jpeg"
        case JPG = "jpg"
        case TIFF = "tiff"
    }
    
    enum mime: String {
        case PNG = "image/png"
        case IJPEG = "image/jpeg"
        case IJPG = "image/jpg"
    }
    
    
    enum dir: String {
        case Images = "Images"
    }
    
    enum imgf: String {
        case profilePicture = "profilePicture"
    }
    
    

    
}
