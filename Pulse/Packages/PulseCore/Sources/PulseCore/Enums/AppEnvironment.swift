//
//  AppEnvironment.swift
//
//
//  Created by Bahdan Piatrouski on 8.03.24.
//

import Foundation

public enum AppEnvironment: String, CaseIterable {
    case local
    case test
    case releaseDebug = "release.debug"
    case releaseProd  = "release.prod"
    
    static var environmentByScheme: AppEnvironment {
        #if LOCAL
        return .local
        #elseif TEST
        return .test
        #elseif RELEASE_D
        return .releaseDebug
        #elseif DEBUG
        return .releaseDebug
        #else
        return .releaseProd
        #endif
    }
    
    public static var current: AppEnvironment {
        get {
            #if RELEASE_P
            return .releaseProd
            #endif
            if let rawEnvironemnt = UserDefaults.standard.value(forKey: .appEnvironment) as? String,
               let environment = Self(rawValue: rawEnvironemnt) {
                return environment
            } else {
                UserDefaults.standard.setValue(
                    Self.environmentByScheme.rawValue,
                    forKey: .appEnvironment
                )
                
                return Self.environmentByScheme
            }
        }
        set {
            #if !RELEASE_P
            UserDefaults.standard.setValue(
                newValue.rawValue,
                forKey: .appEnvironment
            )
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
