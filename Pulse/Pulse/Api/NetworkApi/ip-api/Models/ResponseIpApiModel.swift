//
//  ResponseIpApiModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

typealias IpModel = ResponseIpApiModel

final class ResponseIpApiModel: Decodable {
    let status     : String
    let countryCode: String?
    let city       : String?
    let provider   : String?
    let country    : String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case countryCode
        case city
        case provider = "isp"
        case country
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.provider = try container.decodeIfPresent(String.self, forKey: .provider)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
    }
}
