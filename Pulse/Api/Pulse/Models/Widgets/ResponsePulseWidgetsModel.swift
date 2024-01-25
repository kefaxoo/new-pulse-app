//
//  ResponsePulseWidgetsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import Foundation

enum PulseWidgetsScheme: String {
    case stories
    case exclusiveSongs
    case categories
    case none
    
    var cellId: String {
        switch self {
            case .stories:
                return StoriesTableViewCell.id
            case .exclusiveSongs:
                return TrackTableViewCell.id
            case .categories:
                return PlaylistsCollectionTableViewCell.id
            case .none:
                return ""
        }
    }
}

final class ResponsePulseWidgetsModel: Decodable {
    let exclusiveTracks: PulseWidget<PulseExclusiveTrack>?
    let stories        : PulseWidget<PulseStory>?
    let categories     : PulseWidget<PulsePlaylist>?
    
    var scheme: [PulseWidgetsScheme] {
        var scheme = [PulseWidgetsScheme]()
        if let stories {
            let availableStories = stories.content.filter({ story in
                let track = story.track
                guard track.source != .none && track.service != .none else { return false }
                
                switch track.source {
                    case .muffon, .pulse:
                        return true
                    case .soundcloud:
                        return SettingsManager.shared.soundcloud.isSigned
                    case .yandexMusic:
                        return SettingsManager.shared.yandexMusic.isSigned
                    default:
                        return false
                }
            })
            
            if !availableStories.isEmpty { 
                scheme.append(.stories)
            }
        }
        
        if exclusiveTracks != nil {
            scheme.append(.exclusiveSongs)
        }
        
        if categories != nil {
            scheme.append(.categories)
        }
        
        return scheme
    }

    enum CodingKeys: CodingKey {
        case exclusiveTracks
        case stories
        case categories
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.exclusiveTracks = try container.decodeIfPresent(PulseWidget<PulseExclusiveTrack>.self, forKey: .exclusiveTracks)
        self.stories = try container.decodeIfPresent(PulseWidget<PulseStory>.self, forKey: .stories)
        self.categories = try container.decodeIfPresent(PulseWidget<PulsePlaylist>.self, forKey: .categories)
    }
}
