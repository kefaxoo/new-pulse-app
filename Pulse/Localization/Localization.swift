//
//  Localization.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

enum Localization {}

// MARK: -
// MARK: Words
extension Localization {
    enum Words: String {
        case signIn   = "words.sign.in"
        case signUp   = "words.sign.up"
        case email    = "words.email"
        case password = "words.password"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Controllers
extension Localization {
    enum Controllers {
        enum Auth {}
        enum SignIn {}
    }
}

// MARK: Auth
extension Localization.Controllers.Auth {
    enum Buttons: String {
        case continueWithApple = "controller.auth.button.continue.with.apple"
        case continueWithGoogle = "controller.auth.button.continue.with.google"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Sign In
extension Localization.Controllers.SignIn {
    enum Buttons: String {
        case forgetPassword = "controller.signIn.button.forget.password"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Server localization
extension Localization {
    enum Server {}
}

// MARK: Localization keys
extension Localization.Server {
    enum Keys: String {
        /// Usage: .localization(with:)
        case isIncorrect = "error.something.is.incorrect"
        
        /// Usage: .localization
        case anotherSignMethod = "error.try.another.sign.method"
        
        /// Usage: .localization(with:)
        case isExist = "error.something.is.exist"
        
        /// Usage: .localization
        case exception = "error.exception"
        
        /// Usage: .localization(with:)
        case notFound = "error.something.not.found"
        
        var localization: String {
            return self.rawValue.localized
        }
        
        func localization(with parameter: String) -> String {
            return self.rawValue.localized(parameters: [parameter])
        }
    }
}

// MARK: Localization parameters
extension Localization.Server {
    enum Words: String {
        case email = "word.email"
        case user  = "word.user"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Lines
extension Localization {
    enum Lines: String {
        /// Usage: .localization(with:)
        case unknownError = "lines.unknown.error"
        
        /// Usage: .localization
        case passwordDoesntMeetRequirements = "lines.password.doesnt.meet.requirements"
        
        /// Usage: .localization(with:)
        case textInTextFieldIsEmpty = "lines.text.in.textfield.is.empty"
        
        func localization(with parameters: String...) -> String {
            return self.rawValue.localized(parameters: parameters)
        }
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Alert
