//
//  LogManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class LogManager {
    static let shared = LogManager()
    
    fileprivate init() {}
    
    func sendLog(_ model: LogModel) {
        PulseProvider.shared.sendLog(model)
    }
}
