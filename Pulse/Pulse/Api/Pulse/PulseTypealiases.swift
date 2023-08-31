//
//  PulseTypealiases.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

// MARK: -
// MARK: Models
typealias PulseError      = ResponsePulseErrorModel
typealias PulseCover      = ResponsePulseCoverModel
typealias PulseCoverInfo  = ResponsePulseCoverInfoModel
typealias PulseSuccess    = ResponsePulseSuccessModel
typealias PulseCreateUser = ResponsePulseCreateUserModel
typealias PulseLoginUser  = ResponsePulseLoginUserModel

// MARK: -
// MARK: Closures
typealias PulseDefaultErrorClosure = ((PulseError?) -> ())
