//
//  ResponsePulseSpotifyCanvasModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.01.24.
//

import Foundation

enum SpotifyCanvasType: String {
    case video
    case image
    case none = ""
    
    var canvasType: CanvasView.CanvasType {
        switch self {
            case .video:
                return .video
            case .image:
                return .image
            case .none:
                return .none
        }
    }
}

final class ResponsePulseSpotifyCanvasModel: Decodable {
    let canvasLink: String
    let canvasType: SpotifyCanvasType
    
    enum CodingKeys: String, CodingKey {
        case canvasLink
        case canvasType = "canvasFormat"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.canvasLink = try container.decode(String.self, forKey: .canvasLink)
        if let canvasTypeRaw = try? container.decode(String.self, forKey: .canvasType),
           let canvasType = SpotifyCanvasType(rawValue: canvasTypeRaw) {
            self.canvasType = canvasType
        } else {
            self.canvasType = .none
        }
    }
}
