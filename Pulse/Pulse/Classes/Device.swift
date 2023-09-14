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
    
    var deviceCode: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(
            to: &systemInfo.machine, {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: 1, {
                        String(validatingUTF8: $0)    
                    }
                )
            }
        )
        
        return modelCode
    }
    
    var deviceModel: String {
        return UIDevice.current.model
    }
    
    var systemInfo: String {
        let device = UIDevice.current
        return "\(device.systemName) \(device.systemVersion)"
    }
    
    fileprivate init() {}
}
