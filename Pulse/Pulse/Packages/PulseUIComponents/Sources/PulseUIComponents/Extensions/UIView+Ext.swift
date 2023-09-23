//
//  UIView+Ext.swift
//
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit

extension UIView {
    convenience init(color: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = color
    }
}
