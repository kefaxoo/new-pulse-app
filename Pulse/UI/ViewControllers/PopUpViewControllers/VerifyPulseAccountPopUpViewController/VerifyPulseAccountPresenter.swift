//
//  VerifyPulseAccountPresenter.swift
//  Pulse
//
//  Created by ios on 31.08.23.
//

import UIKit

final class VerifyPulseAccountPresenter: BasePresenter {
    private let verificationCodeModel: VerificationCode
    
    var verificationCodeAsString: String {
        return "\(verificationCodeModel.code)"
    }
    
    var descriptionText: String {
        return Localization.PopUp.VerifyPulseAccount.description.localization(with: self.verificationCodeAsString)
    }
    
    init(verificationCode: VerificationCode) {
        self.verificationCodeModel = verificationCode
    }
    
    func openTelegramBot() {
        guard let url = URL(string: verificationCodeModel.link) else { return }
        
        UIApplication.shared.open(url)
    }
}
