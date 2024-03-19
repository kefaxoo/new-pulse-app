//
//  UIApplication+Ext.swift
//
//
//  Created by Bahdan Piatrouski on 18.02.24.
//

import UIKit

public extension UIApplication {
    var nonDeprecatedKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return self.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?
                .windows.first(where: { $0.isKeyWindow })
        } else {
            return self.keyWindow
        }
    }
}
