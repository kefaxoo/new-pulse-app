//
//  SoundcloudTypealiases.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation

// MARK: -
// MARK: Models

// MARK: - Base
public typealias SoundcloudError = ResponseSoundcloudErrorModel

// MARK: - OAuth
public typealias SoundcloudToken = ResponseSoundcloudTokenModel

// MARK: - User
public typealias SoundcloudUserInfo = ResponseSoundcloudUserInfoModel

// MARK: -
// MARK: Closures
public typealias SoundcloudSignCompletion = ((_ tokens: SoundcloudToken?, _ error: SoundcloudError?) -> ())
public typealias SoundcloudErrorCompletion = ((_ error: SoundcloudError?) -> ())
