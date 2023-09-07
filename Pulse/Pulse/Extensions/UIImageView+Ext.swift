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
}
