//
//  UIApplication+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.10.23.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?
            .windows
            .first(where: \.isKeyWindow)
    }
}
