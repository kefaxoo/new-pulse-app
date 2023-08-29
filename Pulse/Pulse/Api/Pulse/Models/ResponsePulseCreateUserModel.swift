//
//  ResponsePulseCreateUserModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import Foundation

final class ResponsePulseCreateUserModel: Decodable {
    let success         : String
    let message         : String
    let verificationCode: Int
    let image           : String
    
    enum CodingKeys: CodingKey {
        case success
        case message
        case verificationCode
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try container.decode(String.self, forKey: .success)
        self.message = try container.decode(String.self, forKey: .message)
        self.verificationCode = try container.decode(Int.self, forKey: .verificationCode)
        self.image = try container.decode(String.self, forKey: .image)
    }
}
