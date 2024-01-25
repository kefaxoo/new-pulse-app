//
//  UIImageView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

extension UIImageView {
    func setImage(from link: String?, completion: (() -> ())? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            ImageManager.shared.image(from: link) { [weak self] image, shouldAnimate in
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    completion?()
                    guard shouldAnimate else { return }
                    
                    self?.setImage(image)
                }
            }
        }
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image
        self.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) { [weak self] in
            self?.alpha = 1
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
    
    func setImage(_ type: Constants.Images) {
        self.image = type.image
    }
    
    static func imageView(forLabel label: TrackModel.Labels) -> UIImageView {
        let imageView = Self.default
        imageView.setImage(label.image)
        imageView.tintColor = .label
        return imageView
    }
}
