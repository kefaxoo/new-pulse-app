//
//  AppEnvironment.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.09.23.
//

import Foundation

enum AppEnvironment: String {
    case local
    case test
    case releaseDebug
    case releaseProd
    
    static var current: AppEnvironment {
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
}
