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
                return Localization.Words.blue.localization
            case .cyan:
                return Localization.Words.cyan.localization
            case .green:
                return Localization.Words.green.localization
            case .indigo:
                return Localization.Words.indigo.localization
            case .mint:
                return Localization.Words.mint.localization
            case .orange:
                return Localization.Words.orange.localization
            case .pink:
                return Localization.Words.pink.localization
            case .purple:
                return Localization.Words.purple.localization
            case .red:
                return Localization.Words.red.localization
            case .teal:
                return Localization.Words.teal.localization
            case .yellow:
                return Localization.Words.yellow.localization
        }
    }
    
    func isEqual(to color: ColorType) -> UIMenuElement.State {
        return color == self ? .on : .off
    }
}
