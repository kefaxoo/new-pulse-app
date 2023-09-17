//
//  SoundcloudTypealiases.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

typealias SoundcloudToken    = ResponseSoundcloudTokenModel
typealias SoundcloudError    = ResponseSoundcloudErrorModel
typealias SoundcloudUserInfo = ResponseSoundcloudUserInfoModel

typealias SoundcloudDefualtErrorClosure = ((SoundcloudError?) -> ())
