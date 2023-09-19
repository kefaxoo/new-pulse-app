//
//  AudioManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

struct UpdatedTrack {
    let track   : TrackModel
    let response: Decodable?
}

final class AudioManager {
    static let shared = AudioManager()
    
    fileprivate init() {}
    
    func updatePlayableLink(for track: TrackModel, success: @escaping((UpdatedTrack) -> ()), failure: (() -> ())? = nil) {
        switch track.source {
            case .muffon:
                MuffonProvider.shared.trackInfo(track, shouldCancelTask: false) { muffonTrack in
                    let track = TrackModel(muffonTrack)
                    success(UpdatedTrack(track: track, response: muffonTrack))
                } failure: {
                    failure?()
                }
            case .soundcloud:
                SoundcloudProvider.shared.fetchPlayableLinks(id: track.id, shouldCancelTask: false) { playableLinks in
                    track.playableLinks = PlayableLinkModel(playableLinks.streamingLink)
                    success(UpdatedTrack(track: track, response: playableLinks))
                } failure: { _ in
                    failure?()
                }
            case .none:
                failure?()
        }
    }
    
    func convertPlaylist(_ playlist: [Decodable], source: SourceType) -> [TrackModel]? {
        switch source {
            case .muffon:
                guard let playlist = playlist as? [MuffonTrack] else { return nil }
                
                return playlist.map({ TrackModel($0) })
            case .soundcloud:
                guard let playlist = playlist as? [SoundcloudTrack] else { return nil }
                
                return playlist.map({ TrackModel($0) })
            default:
                return nil
        }
    }
    
    func getLocalLink(for track: TrackModel) -> String? {
        guard !track.cachedFilename.isEmpty else { return nil }
        
        return URL(filename: track.cachedFilename, path: .documentDirectory)?.absoluteString
    }
}
