//
//  ImageManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit
import SDWebImage

final class ImageManager {
    static let shared = ImageManager()
    
    fileprivate init() {}
    
    func image(from link: String, imageClosure: @escaping((UIImage?) -> ())) {
        if let image = SDImageCache.shared.imageFromCache(forKey: link) {
            imageClosure(image)
            return
        }
        
        SDWebImageManager.shared.loadImage(with: URL(string: link), progress: nil) { image, _, error, _, _, _ in
            guard error != nil else {
                imageClosure(UIImage(systemName: Constants.Images.System.exclamationMark))
                return
            }
            
            imageClosure(image)
        }
    }
}
