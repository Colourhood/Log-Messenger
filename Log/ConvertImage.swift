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
            return imageData
        }
        return nil
    }

    static func convertUIImageToJPEGData(image: UIImage) -> Data? {
        if let imageData = UIImageJPEGRepresentation(image, 1) {
            resizeImageOptimization(imageData: imageData)
            return imageData
        }
        return nil
    }

    private static func resizeImageOptimization(imageData: Data) {
        let originalImageSizeKB = imageData.count/1024 // turning bytes into kylobytes through this equation
        let optimalImageSizeKB = 80
        print("Image size \(originalImageSizeKB)")
        let resizePercentage = (optimalImageSizeKB/originalImageSizeKB) * 100
//        if originalImageSizeKB > optimalImageSizeKB {
//            let decimalNumber = optimalImageSizeKB/originalImageSizeKB
//            let image = UIImage(data: imageData)
//            let resizedImageData = UIImageJPEGRepresentation(image!, CGFloat(decimalNumber))
//
//            print("Image resizing completed: \((resizedImageData?.count)!/1024)")
//            resizeImageOptimization(imageData: resizedImageData!)
//        }
        let image = UIImage(data: imageData)?.resized(withPercentage: CGFloat(resizePercentage))
        let resizeImageData = UIImageJPEGRepresentation(image!, 1);
        let resizeKB = (resizeImageData?.count)!/1024

        print("resizeImaged size: \(resizeKB)");
    }

}

extension UIImage {

    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

}
