//
//  UIImageView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

extension UIImageView {
    func setImage(from link: String) {
        ImageManager.shared.image(from: link) { [weak self] image in
            self?.image = image
        }
    }
    
    static var defaultImageView: UIImageView {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    static var explicitImageView: UIImageView {
        let imageView = self.defaultImageView
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.image = UIImage(systemName: Constants.Images.System.eInFilledSquare)
        return imageView
    }
    
    static var chevronRightImageView: UIImageView {
        let imageView = self.defaultImageView
        imageView.tintColor = .label.withAlphaComponent(0.7)
        imageView.image = UIImage(systemName: Constants.Images.System.chevronRight)
        return imageView
    }
}
