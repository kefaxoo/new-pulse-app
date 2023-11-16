//
//  Date+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

extension Date {
    static func currentDate(inFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inFormat
        return dateFormatter.string(from: Date())
    }
}
