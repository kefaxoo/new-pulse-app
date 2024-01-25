//
//  CanvasManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.12.23.
//

import Foundation

final class CanvasManager {
    static let shared = CanvasManager()
    
    private var task: Task<Void, Never>?
    
    typealias CanvasCompletion = ((_ link: String, _ canvasType: CanvasView.CanvasType) -> ())
    
    fileprivate init() {}
    
    func fetchCanvasForCurrentTrack(completion: @escaping CanvasCompletion) {
        guard SettingsManager.shared.isCanvasesEnabled,
              let track = AudioPlayer.shared.track
        else { return }
        
        switch track.service {
            case .yandexMusic:
                self.fetchPulseCanvas(for: track, completion: completion)
            case .pulse:
                if let canvasLink = track.canvasLink {
                    completion(canvasLink, .video)
                } else if track.yandexMusicId != nil {
                    self.fetchYandexMusicCanvas(for: track, completion: completion)
                } else if track.spotifyId != nil {
                    self.fetchSpotifyCanvas(for: track, completion: completion)
                } else {
                    PulseProvider.shared.exclusiveTrackInfo(track) { track in
                        guard let canvasLink = track.canvasLink else { return }
                        completion(canvasLink, .video)
                    }
                }
            case .deezer:
                self.fetchPulseCanvas(for: track, completion: completion)
            default:
                return
        }
    }
    
    private func fetchSpotifyCanvas(for track: TrackModel, completion: @escaping CanvasCompletion) {
        PulseProvider.shared.spotifyCanvas(track: track) { spotifyCanvas in
            completion(spotifyCanvas.canvasLink, spotifyCanvas.canvasType.canvasType)
        }
    }
    
    private func fetchYandexMusicCanvas(for track: TrackModel, completion: @escaping CanvasCompletion) {
        if track.service == .yandexMusic {
            YandexMusicProvider.shared.trackInfo(id: track.yandexMusicId != nil ? "\(track.yandexMusicId!)" : track.id) { [weak self] ymTrack in
                if let canvasLink = ymTrack.canvasLink {
                    completion(canvasLink, .video)
                } else {
                    self?.fetchSpotifyCanvas(for: track, completion: completion)
                }
            }
        } else {
            OdesliProvider.shared.fetchTrackLinks(for: track) { root in
                if let yandexMusicId = root.services.links.first(where: { $0.type == .yandexMusic })?.id {
                    YandexMusicProvider.shared.trackInfo(id: yandexMusicId) { [weak self] ymTrack in
                        if let canvasLink = ymTrack.canvasLink {
                            completion(canvasLink, .video)
                        } else {
                            self?.fetchSpotifyCanvas(for: track, completion: completion)
                        }
                    }
                } else {
                    self.fetchSpotifyCanvas(for: track, completion: completion)
                }
            }
        }
    }
    
    private func fetchPulseCanvas(for track: TrackModel, completion: @escaping CanvasCompletion) {
        PulseProvider.shared.pulseCanvas(track: track) { canvas in
            completion(canvas.canvasLink, .video)
        } failure: { [weak self] in
            self?.fetchYandexMusicCanvas(for: track, completion: completion)
        }
    }
}
