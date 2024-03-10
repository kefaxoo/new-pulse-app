//
//  ResponsePulseBaseSuccessModel.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation

public class ResponsePulseSuccessModel: ResponsePulseBaseModel {
    public let success: String
    
    enum CodingKeys: CodingKey {
        case success
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try container.decode(String.self, forKey: .success)
        
        try super.init(from: decoder)
    }
}
