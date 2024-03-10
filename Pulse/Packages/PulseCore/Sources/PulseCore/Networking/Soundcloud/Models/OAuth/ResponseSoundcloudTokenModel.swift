//
//  ResponseSoundcloudTokenModel.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation

public final class ResponseSoundcloudTokenModel: Decodable {
    public let accessToken: String
    public let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}
