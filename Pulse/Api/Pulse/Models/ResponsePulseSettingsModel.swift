//
//  ResponsePulseSettingsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseSettingsModel: Decodable {
    let autoDownload   : Bool
    let isCanvasEnabled: Bool
    let color          : ColorType
    let appearance     : ApplicationStyle
    let soundcloud     : PulseServiceSettings
    let yandexMusic    : PulseServiceSettings
    
    enum CodingKeys: CodingKey {
        case autoDownload
        case isCanvasEnabled
        case color
        case appearance
        case soundcloud
        case yandexMusic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.autoDownload = try container.decode(Bool.self, forKey: .autoDownload)
        self.isCanvasEnabled = try container.decode(Bool.self, forKey: .isCanvasEnabled)
        self.color = ColorType(rawValue: try container.decode(String.self, forKey: .color)) ?? .purple
        self.appearance = ApplicationStyle(rawValue: try container.decode(String.self, forKey: .appearance)) ?? .system
        self.soundcloud = try container.decode(PulseServiceSettings.self, forKey: .soundcloud)
        self.yandexMusic = try container.decode(PulseServiceSettings.self, forKey: .yandexMusic)
    }
}
