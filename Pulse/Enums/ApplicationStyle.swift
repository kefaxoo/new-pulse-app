//
//  ApplicationStyle.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 31.12.23.
//

import UIKit

enum ApplicationStyle: String, CaseIterable {
    case light
    case dark
    case system
    
    var userIntefaceStyle: UIUserInterfaceStyle {
        switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return .unspecified
        }
    }
    
    var title: String {
        switch self {
            case .light:
                return Localization.Enums.ApplicationStyle.Title.light.localization
            case .dark:
                return Localization.Enums.ApplicationStyle.Title.dark.localization
            case .system:
                return Localization.Enums.ApplicationStyle.Title.system.localization
        }
    }
    
    func isEqual(to style: ApplicationStyle) -> UIMenuElement.State {
        return style == self ? .on : .off
    }
}
