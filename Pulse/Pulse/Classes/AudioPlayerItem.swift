//
//  AudioPlayerItem.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.10.23.
//

import AVFoundation

class AudioPlayerItem: AVPlayerItem {
    private var track: TrackModel?
    
    convenience init?(track: TrackModel) {
        guard let link = track.playableLinks?.streaming,
              let url = URL(string: link)
        else { return nil }
        
        self.init(url: url)
        self.track = track
    }
    
    static func initialize(with track: TrackModel, prepare: Bool = false, completion: @escaping((AudioPlayerItem?) -> ())) {
        AudioManager.shared.updatePlayableLink(for: track) { updatedTrack in
            let playerItem = AudioPlayerItem(track: updatedTrack.track)
            completion(playerItem)
            playerItem?.prepare()
        } failure: {
            completion(nil)
        }
    }
    
    func prepare() {
        guard let track else { return }
        
        SessionCacheManager.shared.addTrackToQueue(track)
    }
}
