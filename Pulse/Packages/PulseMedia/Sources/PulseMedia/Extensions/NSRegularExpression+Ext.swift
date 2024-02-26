//
//  File.swift
//  
//
//  Created by Bahdan Piatrouski on 26.02.24.
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
