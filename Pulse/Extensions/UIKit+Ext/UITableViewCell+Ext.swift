//
//  UITableViewCell+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import UIKit

extension UITableViewCell {
    static var id: String {
        return String(describing: self.self)
    }
}
