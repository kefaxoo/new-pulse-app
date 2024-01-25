//
//  ResponsePulseStoryModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseStoryModel: Decodable {
    let id: Int
    let track: PulseStoryTrack
    var didUserWatch: Bool
    let storyType: PulseStoryType
    var trackObj: TrackModel?
    
    enum CodingKeys: CodingKey {
        case id
        case track
        case didUserWatch
        case storyType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.id = try container.decode(Int.self, forKey: .id)
        self.track = try container.decode(PulseStoryTrack.self, forKey: .track)
        self.didUserWatch = try container.decode(Bool.self, forKey: .didUserWatch)
        self.storyType = try container.decode(PulseStoryType.self, forKey: .storyType)
    }
}
