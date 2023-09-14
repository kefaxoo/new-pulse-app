//
//  UIColor+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        var hexCode = hex
        if hexCode.hasPrefix("#") {
            hexCode = hexCode.replacingOccurrences(of: "#", with: "")
        }
        
        let start = hexCode.index(hexCode.startIndex, offsetBy: 0)
        let hexColor = String(hexCode[start...])
        guard hexColor.count == 6 else { return nil }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        b = CGFloat(hexNumber & 0x0000ff) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1)
        return
    }
}
