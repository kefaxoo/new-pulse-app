//
//  Constants.swift
//
//
//  Created by Bahdan Piatrouski on 8.03.24.
//

import Foundation

enum Constants {}

// MARK: -
// MARK: UserDefaultsKeys
extension Constants {
    enum UserDefaultsKeys: String {
        case appEnvironment
        
        // MARK: - Device info
        case deviceCountry
        
        // MARK: - Soundcloud
        case soundcloudUserId
        case soundcloudUser
        case soundcloudSource = "soundcloud.source"
    }
}

// MARK: -
// MARK: KeychainService
extension Constants {
    enum KeychainServices: String {
        // MARK: - Soundcloud
        case soundcloudAccessToken
        case soundcloudRefreshToken
    }
}
