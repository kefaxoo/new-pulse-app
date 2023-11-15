//
//  UIImage+Ext.swift
//
//
//  Created by Bahdan Piatrouski on 14.11.23.
//

import UIKit

extension UIImage {
    func resizeImage(to size: CGSize) -> UIImage? {
        let imageSize = self.size
        let widthRatio = size.width / imageSize.width
        let heightRatio = size.height / imageSize.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let image = self
        
        let rectangle = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: rectangle)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
