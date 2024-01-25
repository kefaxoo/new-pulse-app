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
        
        if track.needFetchingPlayableLinks {
            self.updatePlayableLink(for: track, success: success, failure: failure)
        } else {
            success(UpdatedTrack(track: track, response: nil))
        }
    }
    
    func updatePlayableLink(for track: TrackModel, success: @escaping((UpdatedTrack) -> ()), failure: (() -> ())? = nil) {
        switch track.source {
            case .muffon:
                if track.service == .yandexMusic,
                   SettingsManager.shared.yandexMusic.isSigned {
                    YandexMusicProvider.shared.fetchAudioLink(for: track, shouldCancelTask: false) { link in
                        guard let link else {
                            failure?()
                            return
                        }
                        
                        track.playableLinks = PlayableLinkModel(link)
                        success(UpdatedTrack(track: track, response: nil))
                    }
                    
                    return
                }
                        
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
            case .yandexMusic:
                if SettingsManager.shared.yandexMusic.isSigned {
                    YandexMusicProvider.shared.fetchAudioLink(for: track, shouldCancelTask: false) { link in
                        guard let link else {
                            failure?()
                            return
                        }
                        
                        track.extension = SettingsManager.shared.yandexMusic.streamingQuality.fileExtension
                        track.playableLinks = PlayableLinkModel(link)
                        success(UpdatedTrack(track: track, response: nil))
                    }
                } else {
                    MuffonProvider.shared.trackInfo(track, shouldCancelTask: false) { muffonTrack in
                        let track = TrackModel(muffonTrack)
                        success(UpdatedTrack(track: track, response: muffonTrack))
                    } failure: {
                        failure?()
                    }
                }
            case .pulse:
                PulseProvider.shared.exclusiveTrackInfo(track) { track in
                    success(UpdatedTrack(track: TrackModel(track), response: track))
                } failure: { _, _ in
                    failure?()
                }
            default:
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
            case .yandexMusic:
                guard let playlist = playlist as? [YandexMusicTrack] else { return nil }
                
                return playlist.map({ TrackModel($0) })
            case .pulse:
                guard let playlist = playlist as? [PulseExclusiveTrack] else { return nil }
                
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
