//
//  UITextField+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

extension UITextField {
    @objc convenience init(withPlaceholder: String) {
        self.init()
        self.placeholder = withPlaceholder
    }
}
