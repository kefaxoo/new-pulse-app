//
//  UIDevice+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.02.24.
//

import UIKit

extension UIDevice {
    var deviceIdentifier: String {
        if self.isSimulator {
            return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8,
                  value != 0
            else { return identifier }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #endif
        
        return false
    }
}
