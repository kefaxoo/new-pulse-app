//
//  Int+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.09.23.
//

import Foundation

extension Int {
    var toDateString: String {
        let deltaInDay = Double(Int(Date().timeIntervalSince1970) - self) / 86400.0
        let date: String
        if deltaInDay < 1 {
            date = "today"
        } else if deltaInDay < 2 {
            date = "yesterday"
        } else if deltaInDay < 7 {
            let days = Int(trunc(deltaInDay))
            date = "\(days) days ago"
        } else if deltaInDay < 30 {
            let weeks = Int(trunc(deltaInDay / 7))
            date = "\(weeks) weeks ago"
        } else if deltaInDay < 365 {
            let months = Int(trunc(deltaInDay) / 30)
            date = "\(months) months ago"
        } else {
            let years = Int(trunc(deltaInDay) / 365)
            date = "\(years) years ago"
        }
        
        return "Last update: \(date)"
    }
}
