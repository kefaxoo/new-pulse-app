//
//  debugLog.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation

func debugLog(_ items: Any?...) {
#if DEBUG
    let line = items.map({ String(describing: $0) }).joined(separator: " ")
    print(line)
#endif
}
