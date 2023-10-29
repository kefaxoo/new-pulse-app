//
//  ServicesManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ServicesManager {
    static let shared = ServicesManager()
    
    fileprivate init() {}
    
    func refreshTokens() {
        if SettingsManager.shared.soundcloud.isSigned {   
            SoundcloudProvider.shared.refreshToken { tokens in
                SettingsManager.shared.soundcloud.updateTokens(tokens)
            } failure: { _ in
                _ = SettingsManager.shared.soundcloud.signOut()
            }
        }
    }
}
