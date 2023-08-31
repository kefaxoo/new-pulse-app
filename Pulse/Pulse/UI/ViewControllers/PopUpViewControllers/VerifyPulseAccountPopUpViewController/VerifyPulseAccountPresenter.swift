//
//  VerifyPulseAccountPresenter.swift
//  Pulse
//
//  Created by ios on 31.08.23.
//

import Foundation

final class VerifyPulseAccountPresenter: BasePresenter {
    private let verificationCodeModel: PulseCreateUser
    
    var verificationCodeAsString: String {
        return "\(verificationCodeModel.verificationCode)"
    }
    
    var descriptionText: String {
        return "To verify account, go to Telegram bot and enter \\verify \(self.verificationCodeAsString)"
    }
    
    init(verificationCodeModel: PulseCreateUser) {
        self.verificationCodeModel = verificationCodeModel
    }
    
    func openTelegramBot() {
        
    }
}
