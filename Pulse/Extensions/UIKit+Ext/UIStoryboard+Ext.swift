//
//  UIStoryboard+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.11.23.
//

import UIKit

extension UIStoryboard {
    static let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil)
    
    var viewController: UIViewController? {
        return self.instantiateInitialViewController()
    }
}
