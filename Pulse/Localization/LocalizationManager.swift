//
//  LocalizationManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.11.23.
//

import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    func localizeError(server serverError: PulseBaseErrorModel?, internal internalError: Error?, default defaultError: String? = nil) -> String {
        var error = ""
        if let serverError,
           let localizationType = Localization.Server.Keys(rawValue: serverError.localizationKey) {
            if let parameter = serverError.localizationParameter,
               let parameterType = Localization.Server.Words(rawValue: parameter) {
                error = localizationType.localization(with: parameterType.localization)
            } else {
                error = localizationType.localization
            }
        } else if let internalError {
            error = internalError.localizedDescription
        } else if let defaultError {
            error = defaultError
        }
        
        return error
    }
}
