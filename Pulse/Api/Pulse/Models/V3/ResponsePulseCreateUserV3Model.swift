//
//  ResponsePulseCreateUserV3Model.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

final class ResponsePulseCreateUserV3Model: PulseBaseSuccessModel {
    let telegramBotLink : String
    let verificationCode: Int
    
    var verifyModel: VerificationCode {
        return VerificationCode(code: self.verificationCode, link: self.telegramBotLink)
    }
    
    enum CodingKeys: CodingKey {
        case telegramBotLink
        case verificationCode
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.telegramBotLink = try container.decode(String.self, forKey: .telegramBotLink)
        self.verificationCode = try container.decode(Int.self, forKey: .verificationCode)
        
        try super.init(from: decoder)
    }
}
