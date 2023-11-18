//
//  ResponsePulseFeatureModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation

final class ResponsePulseFeatureModel: Decodable {
    let prod : Bool
    let debug: Bool
    
    var toRealmModel: LocalFeatureModel {
        return LocalFeatureModel(prod: self.prod, debug: self.debug)
    }
    
    enum CodingKeys: CodingKey {
        case prod
        case debug
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.prod = try container.decode(Bool.self, forKey: .prod)
        self.debug = try container.decode(Bool.self, forKey: .debug)
    }
}
