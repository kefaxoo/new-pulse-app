//
//  ServicesManager.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import Foundation

public final class ServicesManager {
    public static let shared = ServicesManager()
    
    public func appStarting() {
        self.refreshTokens()
    }
}

private extension ServicesManager {
    func refreshTokens() {
        if SettingsManager.shared.soundcloud.isSigned {
            SoundcloudProvider.shared.fetchRefreshToken { tokens, error in
                guard let tokens else { return }
                
                SettingsManager.shared.soundcloud.saveOrUpdateTokens(tokens)
            }
        }
    }
}
