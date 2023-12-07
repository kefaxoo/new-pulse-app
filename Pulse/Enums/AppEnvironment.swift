//
//  AppEnvironment.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.09.23.
//

import Foundation

enum AppEnvironment: String, CaseIterable {
    case local        = "local"
    case test         = "test"
    case releaseDebug = "release.debug"
    case releaseProd  = "release.prod"
    
    static var environmentByScheme: AppEnvironment {
#if LOCAL
        return .local
#elseif TEST
        return .test
#elseif RELEASE_D
        return .releaseDebug
#else
        return .releaseProd
#endif
    }
    
    static var current: AppEnvironment {
        get {
#if RELEASE_P
            return .releaseProd
#endif
            if let rawEnvironment = UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.appEnvironment.rawValue) as? String,
               let environment = AppEnvironment(rawValue: rawEnvironment) {
                return environment
            } else {
                UserDefaults.standard.setValue(
                    AppEnvironment.environmentByScheme.rawValue,
                    forKey: Constants.UserDefaultsKeys.appEnvironment.rawValue
                )
                
                return AppEnvironment.environmentByScheme
            }
        }
        set {
#if !RELEASE_P
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKeys.appEnvironment.rawValue)
#endif
        }
    }
    
    var isDebug: Bool {
        return self != .releaseProd
    }
    
    var isRelease: Bool {
        return !self.isDebug
    }
    
    var buttonTitle: String {
        switch self {
            case .local:
                return "Local"
            case .test:
                return "Test"
            case .releaseDebug:
                return "Release Debug"
            case .releaseProd:
                return "Release Production"
        }
    }
}
