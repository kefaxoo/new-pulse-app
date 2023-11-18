//
//  ResponsePulseVerifyUserV3Model.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

final class ResponsePulseVerifyUserV3Model: PulseBaseErrorModel {
    let verificationCode: Int
    let telegramBotLink : String
    
    var verifyModel: VerificationCode {
        return VerificationCode(code: self.verificationCode, link: self.telegramBotLink)
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
