//
//  DownloadQueueTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 11.09.23.
//

import Foundation
import RealmSwift

final class DownloadQueueTrackModel: Object {
    @Persisted dynamic var id      = ""
    @Persisted dynamic var service = ""
    @Persisted dynamic var source  = ""
    
    var filename = ""
    
    convenience init(_ track: TrackModel) {
        self.init()
        
        self.id      = track.id
        self.service = track.service.rawValue
        self.source  = track.source.rawValue
    }
}
