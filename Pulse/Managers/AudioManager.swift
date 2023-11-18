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
    
    func getPlayableLink(for track: TrackModel, success: @escaping((UpdatedTrack) -> ()), failure: (() -> ())? = nil) {
        if !track.cachedFilename.isEmpty,
           let link = self.getLocalLink(for: track) {
            track.playableLinks = PlayableLinkModel(link)
            success(UpdatedTrack(track: track, response: nil))
            return
        }
        
        if SessionCacheManager.shared.isTrackInCache(track),
           let link = SessionCacheManager.shared.getCacheLink(for: track) {
            track.playableLinks = PlayableLinkModel(link)
            success(UpdatedTrack(track: track, response: nil))
            return
        }
        
        self.updatePlayableLink(for: track, success: success, failure: failure)
    }
    
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
                if SettingsManager.shared.soundcloud.isSigned {
                    SoundcloudProvider.shared.fetchPlayableLinks(id: track.id, shouldCancelTask: false) { playableLinks in
                        track.playableLinks = PlayableLinkModel(playableLinks.streamingLink)
                        success(UpdatedTrack(track: track, response: playableLinks))
                    } failure: { _ in
                        failure?()
                    }
                } else {
                    MuffonProvider.shared.trackInfo(track, shouldCancelTask: false) { muffonTrack in
                        let track = TrackModel(muffonTrack)
                        success(UpdatedTrack(track: track, response: muffonTrack))
                    } failure: {
                        failure?()
                    }
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
