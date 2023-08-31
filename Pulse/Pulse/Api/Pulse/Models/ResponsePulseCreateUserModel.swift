//
//  ResponsePulseCreateUserModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import Foundation

final class ResponsePulseCreateUserModel: PulseSuccess {
    let message         : String
    let verificationCode: Int
    let telegramBotLink : String
    
    enum CodingKeys: CodingKey {
        case message
        case verificationCode
        case telegramBotLink
    }
    
    override init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.message = try container.decode(String.self, forKey: .message)
        self.verificationCode = try container.decode(Int.self, forKey: .verificationCode)
        self.telegramBotLink = try container.decode(String.self, forKey: .telegramBotLink)
        
        try super.init(from: decoder)
    }
}
