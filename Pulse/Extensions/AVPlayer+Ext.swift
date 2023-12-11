//
//  AVPlayer+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.12.23.
//

import AVFoundation
import PulseUIComponents

extension AVPlayer {
    var coverState: CoverImageViewState {
        guard self.currentItem?.status == .readyToPlay else { return .loading }
        
        return self.rate == 0 ? .stopped : .playing
    }
}
