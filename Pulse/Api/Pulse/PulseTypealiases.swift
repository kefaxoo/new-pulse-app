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

typealias PulseFeature     = ResponsePulseFeatureModel
typealias PulseFeatures    = ResponsePulseFeaturesModel

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
typealias PulseIsBlocked         = ResponsePulseIsBlockedModel

// Models V3
typealias PulseServerTrack = ResponsePulseServerTrackModel

// Widgets
typealias PulseWidgetsRoot        = ResponsePulseWidgetsRootModel
typealias PulseWidgets            = ResponsePulseWidgetsModel
typealias PulseExclusiveTrack     = ResponsePulseExclusiveTrackModel
typealias PulseExclusiveArtist    = ResponsePulseExclusiveArtistModel
typealias PulseExclusiveAlbum     = ResponsePulseExclusiveAlbumModel
typealias PulseWidget             = ResponsePulseWidgetModel
typealias PulseWidgetRoot         = ResponsePulseWidgetRootModel
typealias PulseExclusiveTrackInfo = ResponsePulseExclusiveTrackInfoModel
typealias PulsePlaylist           = ResponsePulsePlaylistModel
typealias PulsePlaylistRoot       = ResponsePulsePlaylistRootModel

// Stories
typealias PulseStoryTrack = ResponsePulseStoryTrackModel
typealias PulseStoryType  = ResponsePulseStoryTypeModel
typealias PulseStory      = ResponsePulseStoryModel

// Settings
typealias PulseServiceSettings = ResponsePulseServiceSettingsModel
typealias PulseSettings        = ResponsePulseSettingsModel
typealias PulseSettingsRoot    = ResponsePulseSettingsRootModel
typealias PulseQualitySettings = ResponsePulseQualitySettingsModel

typealias PulseSpotifyCanvas = ResponsePulseSpotifyCanvasModel
typealias PulseCanvas        = ResponsePulseCanvasModel

// Device
typealias PulseDeviceInfo = ResponsePulseDeviceInfoModel

// MARK: -
// MARK: Closures
typealias PulseDefaultErrorClosure = ((PulseError?) -> ())

// V3
typealias PulseDefaultErrorV3Closure = ((_ serverError: PulseBaseErrorModel?, _ internalError: Error?) -> ())
