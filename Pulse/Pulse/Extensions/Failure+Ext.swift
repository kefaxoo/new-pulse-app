//
//  Failure+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.09.23.
//

import Foundation
import FriendlyURLSession

extension Failure {
    func sendLog() {
        guard AppEnvironment.current != .local else { return }
        
        if let data = self.data {
            LogManager.shared.sendLog(LogModel(callStack: Thread.callStackSymbols, error: data.toString))
        } else {
            LogManager.shared.sendLog(LogModel(callStack: Thread.callStackSymbols, error: self.error?.localizedDescription))
        }
    }
}
