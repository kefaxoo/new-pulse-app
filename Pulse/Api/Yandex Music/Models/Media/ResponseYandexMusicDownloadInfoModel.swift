//
//  ResponseYandexMusicDownloadInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.12.23.
//

import Foundation

final class ResponseYandexMusicDownloadInfoModel: Decodable {
    let downloadInfoUrl: String
    let bitrate        : Int
    
    enum CodingKeys: String, CodingKey {
        case downloadInfoUrl
        case bitrate = "bitrateInKbps"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.downloadInfoUrl = try container.decode(String.self, forKey: .downloadInfoUrl)
        self.bitrate = try container.decode(Int.self, forKey: .bitrate)
    }
}
