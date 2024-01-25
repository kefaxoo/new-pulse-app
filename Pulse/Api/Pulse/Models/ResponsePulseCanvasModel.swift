//
//  ResponsePulseCanvasModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.01.24.
//

import Foundation

final class ResponsePulseCanvasModel: PulseBaseSuccessModel {
    let canvasLink: String
    
    enum CodingKeys: CodingKey {
        case canvasLink
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.canvasLink = try container.decode(String.self, forKey: .canvasLink)
        
        try super.init(from: decoder)
    }
}
