//
//  UILabel+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

extension UILabel {
    convenience init(text: String?) {
        self.init()
        self.text = text
    }
    
    var textSize: CGSize {
        return self.size(with: self.text)
    }
    
    func size(with text: String? = "0") -> CGSize {
        return text?.size(withAttributes: [.font: self.font as Any]) ?? .zero
    }
}
