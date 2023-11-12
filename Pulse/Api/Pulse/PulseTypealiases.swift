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

typealias PulseDefault     = ResponsePulseDefaultModel
typealias PulseAuthTokens  = ResponsePulseAuthTokensModel
typealias PulseAccessToken = ResponsePulseAccessTokenModel
typealias PulseFeature     = ResponsePulseFeatureModel
typealias PulseFeatures    = ResponsePulseFeaturesModel

// V2
typealias PulseSuccessV2          = ResponsePulseSuccessV2Model
typealias PulseErrorV2            = ResponsePulseErrorV2Model
typealias PulseCreateUserV2       = ResponsePulseCreateUserV2Model
typealias PulseLoginUserV2        = ResponsePulseLoginUserV2Model
typealias PulseVerificationCodeV2 = ResponsePulseVerificationCodeV2Model

// Base
typealias PulseBaseModel        = ResponsePulseBaseModel
typealias PulseBaseSuccessModel = ResponsePulseBaseSuccessModel
typealias PulseBaseErrorModel   = ResponsePulseBaseErrorModel
typealias PulsebaseContentModel = ResponsePulseBaseContentModel

// Sign V3, Library V2, Soundcloud V2
typealias PulseCreateUserV3      = ResponsePulseCreateUserV3Model
typealias PulseAuthorizationInfo = ResponsePulseAuthorizationInfoModel
typealias PulseLoginUserV3       = ResponsePulseLoginUserV3Model
typealias PulseVerifyUserV3      = ResponsePulseVerifyUserV3Model
typealias PulseResetPasswordV3   = ResponsePulseResetPasswordV3Model
typealias PulseAddTracksModels   = ResponsePulseAddTracksModel
typealias PulseImagesModel       = ResponsePulseImagesModel

// Models V3
typealias PulseServerTrack = ResponsePulseServerTrackModel

// MARK: -
// MARK: Closures
typealias PulseDefaultErrorClosure = ((PulseError?) -> ())

// V2
typealias PulseDefaultErrorV2Closure = ((PulseErrorV2?) -> ())

// V3
typealias PulseDefaultErrorV3Closure = ((_ serverError: PulseBaseErrorModel?, _ internalError: Error?) -> ())
