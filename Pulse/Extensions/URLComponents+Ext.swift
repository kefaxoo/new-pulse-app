//
//  URLComponents+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.12.23.
//

import Foundation

extension URLComponents {
    var fullHost: String? {
        guard let http = self.string?.split(separator: ":").first,
              let host = self.host
        else { return nil }
        
        return "\(http)://\(host)"
    }
}
