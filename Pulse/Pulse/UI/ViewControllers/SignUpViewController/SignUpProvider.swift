//
//  SignUpProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

protocol SignUpProviderDelegate: CoversProviderDelegate {}

final class SignUpProvider: CoversProvider<SignUpViewController> {
    func checkTextFrom(textField: UITextField, textFieldKind: String) -> String? {
        guard let text = textField.text,
              !text.isEmpty
        else {
            guard let view = self.delegate?.view else { return nil }
            
            AlertView.shared.present(title: "Error", message: "Text in \(textFieldKind) is empty", alertType: .error, system: .iOS16AppleMusic, on: view)
            return nil
        }
        
        return text
    }
    
    func checkPassword(textField: UITextField) -> String? {
        guard let password = self.checkTextFrom(textField: textField, textFieldKind: "password") else { return nil }
        
        guard NSRegularExpression(Constants.RegularExpressions.pulsePassword).isMatch(password) else {
            guard let view = self.delegate?.view else { return nil }
            
            AlertView.shared.present(title: "Error", message: "Password doesn't meet requirements", alertType: .error, system: .iOS16AppleMusic, on: view)
            return nil
        }
        
        return password
    }
    
    func createUser(credentials: Credentials, success: @escaping((PulseCreateUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        
    }
}
