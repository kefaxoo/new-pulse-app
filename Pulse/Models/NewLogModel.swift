//
//  NewLogModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.02.24.
//

import UIKit
import CallStackParserSPM

struct NewLogModel {
    enum LogErrorType: String {
        case request
        case ui
        case crash
    }
    
    let screenId            : URL
    let errorType           : LogErrorType
    let trace               : String
    var cURL                : String?
    var additionalParameters: [String: Any]?
    
    var json: [String: Any] {
        var parameters: [String: Any] = [
            "appVersion": Bundle.main.releaseVersion as Any,
            "buildNumber": Bundle.main.buildVersion as Any,
            "screenId": self.screenId.absoluteString,
            "deviceModel": SettingsManager.shared.deviceModel,
            "deviceType": UIDevice.current.isSimulator ? "Simulator" : "Device",
            "errorType": self.errorType.rawValue,
            "appEnvironment": AppEnvironment.current.rawValue,
            "systemVersion": UIDevice.current.systemVersion,
            "trace": self.trace,
            "locale": Locale.current.isoLanguageCode,
            "sendTime": [
                "date": Date.currentDate(inFormat: "dd.MM.YYYY"),
                "time": Date.currentDate(inFormat: "HH:mm:ss")
            ]
        ]
        
        if !SettingsManager.shared.pulse.username.isEmpty {
            parameters["userEmail"] = SettingsManager.shared.pulse.username
        }
        
        if let cURL {
            parameters["cURL"] = cURL
        }
        
        if NetworkManager.shared.isReachable,
           NetworkManager.shared.country != nil {
            parameters["networkCountry"] = NetworkManager.shared.countryCode
        }
        
        if let additionalParameters {
            parameters["additionalParameters"] = parameters
        }
        
        return parameters
    }
}
