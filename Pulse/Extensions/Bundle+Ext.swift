//
//  Bundle+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.10.23.
//

import Foundation

extension Bundle {
    var releaseVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
