//
//  ResponseSoundcloudErrorModel.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation

public final class ResponseSoundcloudErrorModel: Decodable {
    public let message: String
    
    enum CodingKeys: CodingKey {
        case message
    }
    
    public init(errorDescription: String) {
        self.message = errorDescription
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.message = try container.decode(String.self, forKey: .message)
    }
}
