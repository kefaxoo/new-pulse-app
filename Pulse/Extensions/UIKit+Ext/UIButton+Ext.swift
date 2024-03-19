//
//  UIButton+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import UIKit

extension UIButton {
    static var defaultHeight: CGFloat {
        return 34
    }
    
    func setImage(_ image: Constants.Images) {
        self.setImage(image.image, for: .normal)
    }
}
