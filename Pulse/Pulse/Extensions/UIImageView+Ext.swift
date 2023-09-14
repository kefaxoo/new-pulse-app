//
//  UIImageView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

extension UIImageView {
    func setImage(from link: String?) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            ImageManager.shared.image(from: link) { [weak self] image in
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                }
            }
        }
    }
    
    static var `default`: UIImageView {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    static var explicitImageView: UIImageView {
        let imageView = self.default
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.image = Constants.Images.explicit.image
        return imageView
    }
    
    static var chevronRightImageView: UIImageView {
        let imageView = self.default
        imageView.tintColor = .label.withAlphaComponent(0.7)
        imageView.image = Constants.Images.chevronRight.image
        return imageView
    }
}
