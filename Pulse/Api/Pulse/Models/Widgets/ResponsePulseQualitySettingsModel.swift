//
//  ResponsePulseQualitySettingsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.01.24.
//

import Foundation

final class ResponsePulseQualitySettingsModel: Decodable {
    let streaming: Int
    let download : Int
    
    enum CodingKeys: CodingKey {
        case streaming
        case download
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.streaming = try container.decode(Int.self, forKey: .streaming)
        self.download = try container.decode(Int.self, forKey: .download)
    }
}
