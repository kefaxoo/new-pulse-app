//
//  ResponsePulseVerificationCodeModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import Foundation

class ResponsePulseVerificationCodeModel: PulseSuccess {
    let verificationCode: Int
    let telegramBotLink : String
    
    var model: VerificationCode {
        return VerificationCode(code: verificationCode, link: telegramBotLink)
    }
    
    enum CodingKeys: CodingKey {
        case verificationCode
        case telegramBotLink
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.verificationCode = try container.decode(Int.self, forKey: .verificationCode)
        self.telegramBotLink = try container.decode(String.self, forKey: .telegramBotLink)
        
        try super.init(from: decoder)
    }
}
