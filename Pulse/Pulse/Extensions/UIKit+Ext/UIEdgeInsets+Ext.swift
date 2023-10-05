//
//  UIEdgeInsets+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

extension UIEdgeInsets {
    init(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
    
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
}
