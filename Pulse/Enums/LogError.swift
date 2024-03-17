//
//  LogError.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 1.03.24.
//

import Foundation

enum LogError: String {
    case appleSignError = "Apple Sign In | Authorization.Credentials is nil"
    case none = ""
    case pulseExternalSign = "Pulse | External Sign"
    case pulseSignIn = "Pulse | Sign In"
}
