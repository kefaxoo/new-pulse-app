//
//  Device.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

final class Device {
    static let current = Device()
    
    var safeAreaInsets: UIEdgeInsets {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets ?? UIEdgeInsets(all: 0)
    }
    
    fileprivate init() {}
}
