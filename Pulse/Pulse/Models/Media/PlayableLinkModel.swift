//
//  PlayableLinkModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

final class PlayableLinkModel {
    let streaming: String
    let offline  : String
    
    var streamingLinkNeedsToRefresh: Bool {
        return streaming.isEmpty
    }
    
    init(_ model: MuffonAudio) {
        streaming = model.link ?? ""
        offline   = model.link ?? ""
    }
}
