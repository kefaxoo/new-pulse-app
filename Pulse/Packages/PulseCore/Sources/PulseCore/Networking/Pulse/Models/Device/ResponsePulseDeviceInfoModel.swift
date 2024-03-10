//
//  ResponsePulseDeviceInfoModel.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation

public final class ResponsePulseDeviceInfoModel: ResponsePulseSuccessModel {
    let countryCode: String?
    
    enum CodingKeys: CodingKey {
        case countryCode
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        
        try super.init(from: decoder)
    }
}
