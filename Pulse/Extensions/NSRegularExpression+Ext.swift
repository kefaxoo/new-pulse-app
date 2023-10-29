//
//  NSRegularExpression+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 31.08.23.
//

import Foundation

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern)")
        }
    }
    
    func isMatch(_ line: String) -> Bool {
        return self.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)) != nil
    }
}
