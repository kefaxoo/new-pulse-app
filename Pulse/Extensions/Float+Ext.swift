//
//  Float+Ext.swift
//  Pulse
//
//  Created by ios on 19.09.23.
//

import Foundation

extension Float {
    var toMinuteAndSeconds: String {
        guard !self.isNaN,
              !self.isInfinite
        else { return "00:00" }
        
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let seconds = totalSeconds % 60
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minutesString):\(secondsString)"
    }
}
