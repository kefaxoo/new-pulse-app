//
//  debugLog.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation

func debugLog(_ items: Any?..., sendLog: Bool = false) {
    let line = items.map({ "\($0 ?? "")" }).joined(separator: " ")
    if AppEnvironment.current != .local,
       sendLog {
        LogManager.shared.sendLog(LogModel(callStack: Thread.callStackSymbols, error: line))
    }
    
    guard AppEnvironment.current != .releaseProd else { return }
    
    print(line)
}
