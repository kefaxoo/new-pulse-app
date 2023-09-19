//
//  Float+Ext.swift
//  Pulse
//
//  Created by ios on 19.09.23.
//

import Foundation

extension Float {
    var toMinuteAndSeconds: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(seconds)"
    }
}
