//
//  ColorType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

enum ColorType: String, CaseIterable {
    case blue   = "blueColor"
    case cyan   = "cyanColor"
    case green  = "greenColor"
    case indigo = "indigoColor"
    case mint   = "mintColor"
    case orange = "orangeColor"
    case pink   = "pinkColor"
    case purple = "purpleColor"
    case red    = "redColor"
    case teal   = "tealColor"
    case yellow = "yellowColor"
    
    var color: UIColor {
        switch self {
            case .blue:
                return UIColor.systemBlue
            case .cyan:
                return UIColor.systemCyan
            case .green:
                return UIColor.systemGreen
            case .indigo:
                return UIColor.systemIndigo
            case .mint:
                return UIColor.systemMint
            case .orange:
                return UIColor.systemOrange
            case .pink:
                return UIColor.systemPink
            case .purple:
                return UIColor.systemPurple
            case .red:
                return UIColor.systemRed
            case .teal:
                return UIColor.systemTeal
            case .yellow:
                return UIColor.yellow
        }
    }
    
    var title: String {
        switch self {
            case .blue:
                return "Blue"
            case .cyan:
                return "Cyan"
            case .green:
                return "Green"
            case .indigo:
                return "Indigo"
            case .mint:
                return "Mint"
            case .orange:
                return "Orange"
            case .pink:
                return "Pink"
            case .purple:
                return "Purple"
            case .red:
                return "Red"
            case .teal:
                return "Teal"
            case .yellow:
                return "Yellow"
        }
    }
}
