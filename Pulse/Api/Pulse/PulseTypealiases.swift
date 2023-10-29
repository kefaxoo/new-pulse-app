//
//  PulseTypealiases.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

// MARK: -
// MARK: Models
typealias PulseError            = ResponsePulseErrorModel
typealias PulseCover            = ResponsePulseCoverModel
typealias PulseCoverInfo        = ResponsePulseCoverInfoModel
typealias PulseSuccess          = ResponsePulseSuccessModel
typealias PulseCreateUser       = ResponsePulseCreateUserModel
typealias PulseLoginUser        = ResponsePulseLoginUserModel
typealias PulseLoginWithCode    = ResponsePulseLoginWithCodeModel
typealias PulseVerificationCode = ResponsePulseVerificationCodeModel
typealias PulseTrack            = ResponsePulseTrackModel
typealias PulseResults          = ResponsePulseResultsModel

// V2
typealias PulseDefault            = ResponsePulseDefaultModel
typealias PulseSuccessV2          = ResponsePulseSuccessV2Model
typealias PulseErrorV2            = ResponsePulseErrorV2Model
typealias PulseCreateUserV2       = ResponsePulseCreateUserV2Model
typealias PulseLoginUserV2        = ResponsePulseLoginUserV2Model
typealias PulseAuthTokens         = ResponsePulseAuthTokensModel
typealias PulseVerificationCodeV2 = ResponsePulseVerificationCodeV2Model
typealias PulseAccessToken        = ResponsePulseAccessTokenModel

// MARK: -
// MARK: Closures
typealias PulseDefaultErrorClosure = ((PulseError?) -> ())

// V2
typealias PulseDefaultErrorV2Closure = ((PulseErrorV2?) -> ())
