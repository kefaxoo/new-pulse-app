//
//  UICollectionViewCell+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

extension UICollectionViewCell {
    static var id: String {
        return String(describing: self.self)
    }
}
