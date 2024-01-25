//
//  LyricsParcer.swift
//
//
//  Created by Bahdan Piatrouski on 12.01.24.
//

import Foundation

public struct LyricsWord {
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    
    var word: String
}

public struct LyricsLine {
    let beginTime: TimeInterval
    let words = [LyricsWord]()
}

public struct Lyrics {
    var lyricsArtist: String?
    var albumName: String?
    var lyricsCreator: String?
    var length: TimeInterval?
    var lrcCreator: String?
    var lyricsTitle: String?
    
    var lines = [LyricsLine]()
}

open class LyricsParser {
    let lyrics: Lyrics
    
    init(withLrcLine: String) {
        self.lyrics = Lyrics()
    }
}
