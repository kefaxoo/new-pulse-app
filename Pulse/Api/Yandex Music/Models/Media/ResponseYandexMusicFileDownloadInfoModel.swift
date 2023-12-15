//
//  ResponseYandexMusicFileDownloadInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.12.23.
//

import Foundation

final class ResponseYandexMusicFileDownloadInfoModel: Decodable {
    fileprivate let sign     : String
    fileprivate let timestamp: String
    fileprivate let path     : String
    fileprivate let host     : String
    
    var link: String {
        return "https://\(host)/get-mp3/\(sign)/\(timestamp)\(path)"
    }
    
    enum CodingKeys: String, CodingKey {
        case sign = "s"
        case timestamp = "ts"
        case path
        case host
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.sign = try container.decode(String.self, forKey: .sign)
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.path = try container.decode(String.self, forKey: .path)
        self.host = try container.decode(String.self, forKey: .host)
    }
}
