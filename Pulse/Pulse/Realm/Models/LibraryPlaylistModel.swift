//
//  LibraryPlaylistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import Foundation
import RealmSwift

final class LibraryPlaylistModel: Object {
    @Persisted dynamic var id         : String = UUID().uuidString
    @Persisted dynamic var title      : String = ""
    @Persisted dynamic var dateCreated: Int = 0
    @Persisted dynamic var dateUpdated: Int = 0
    @Persisted dynamic var trackIds   : List<Int> = List<Int>()
    
    convenience init(title: String, trackIds: [Int], dateCreated: Int = Int(Date().timeIntervalSince1970), dateUpdated: Int? = nil) {
        self.init()
        self.title       = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated ?? dateCreated
        self.trackIds    = List<Int>()
        trackIds.forEach({ self.trackIds.append($0) })
    }
}
