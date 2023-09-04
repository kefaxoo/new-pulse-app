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
    
    static var explicitImageView: UIImageView {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.image = UIImage(systemName: Constants.Images.System.eInFilledSquare)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
