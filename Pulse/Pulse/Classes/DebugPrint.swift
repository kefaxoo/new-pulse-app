//
//  DebugPrint.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation

func debugPring(_ items: Any...) {
#if DEBUG
    let line = items.map({ "\($0)" }).joined(separator: " ")
    print(line)
#endif
}
