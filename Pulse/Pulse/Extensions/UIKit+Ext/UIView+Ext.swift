//
//  UIView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

extension UIView {
    convenience init(with color: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = color
    }
    
    static let spacer = UIView(with: .clear)
}
