//
//  LogModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

struct LogModel {
    let log: [String: Any]
    
    init(callStack: [String], error: String?) {
        self.log = [
            "callStack": callStack.joined(separator: ""),
            "error"    : error ?? ""
        ]
    }
    
    var getFullLog: [String: Any] {
        let deviceInfo: [String: Any] = [
            "name": Device.current.deviceModel,
            "code": Device.current.deviceCode ?? ""
        ]
        
        let networkInfo: [String: Any] = [
            "countryCode": NetworkManager.shared.country,
            "city"       : NetworkManager.shared.city ?? "",
            "provider"   : NetworkManager.shared.provider ?? ""
        ]
        
        return [
            "dateTime": Date.currentDate(inFormat: "YYYY-MM-DD HH.mm.SS.sss"),
            "device"  : deviceInfo,
            "network" : networkInfo,
            "isDebug" : Constants.isDebug,
            "log"     : log
        ]
    }
}
