//
//  ResponsePulseFeaturesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation

final class ResponsePulseFeaturesModel: Decodable {
    let newSign                  : PulseFeature?
    let newLibrary               : PulseFeature?
    let newSoundcloud            : PulseFeature?
    let nowPlayingVC             : PulseFeature?
    let searchSoundcloudPlaylists: PulseFeature?
    let muffonYandex             : PulseFeature?
    
    enum CodingKeys: CodingKey {
        case newSign
        case newLibrary
        case newSoundcloud
        case nowPlayingVC
        case searchSoundcloudPlaylists
        case muffonYandex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.newSign = try container.decodeIfPresent(PulseFeature.self, forKey: .newSign)
        self.newLibrary = try container.decodeIfPresent(PulseFeature.self, forKey: .newLibrary)
        self.newSoundcloud = try container.decodeIfPresent(PulseFeature.self, forKey: .newSoundcloud)
        self.nowPlayingVC = try container.decodeIfPresent(PulseFeature.self, forKey: .nowPlayingVC)
        self.searchSoundcloudPlaylists = try container.decodeIfPresent(PulseFeature.self, forKey: .searchSoundcloudPlaylists)
        self.muffonYandex = try container.decodeIfPresent(PulseFeature.self, forKey: .muffonYandex)
    }
}
