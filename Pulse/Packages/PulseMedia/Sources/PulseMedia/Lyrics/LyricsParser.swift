//
//  LyricsParcer.swift
//
//
//  Created by Bahdan Piatrouski on 12.01.24.
//

import Foundation

public struct LyricsMetadata {
    fileprivate(set) var title     : String?
    fileprivate(set) var artist    : String?
    fileprivate(set) var album     : String?
    fileprivate(set) var length    : String?
    fileprivate(set) var comment   : String?
}

public struct LyricsWord {
    fileprivate(set) var beginTime: String?
    fileprivate(set) var word: String?
}

public struct LyricsLine {
    fileprivate(set) var beginTime: String?
    var line: String? {
        return lineWithoutTimes ?? words?.compactMap({ $0.word }).joined(separator: " ")
    }
    
    fileprivate var lineWithoutTimes: String?
    fileprivate var words: [LyricsWord]?
}

public struct Lyrics {
    fileprivate(set) var metadata: LyricsMetadata?
    fileprivate(set) var lines: [LyricsLine]?
    
    var allText: String? {
        return lines?.compactMap({ $0.line }).joined(separator: "/n")
    }
}

open class LyricsParser {
    fileprivate enum Regex: String, CaseIterable {
        case title      = "ti"
        case artist     = "ar"
        case album      = "al"
        case length     = "length"
        case comment    = "#"
        
        var regex: String {
            return "\\[\(self.rawValue):.+\\]"
        }
            
        var regularExpression: NSRegularExpression {
            return NSRegularExpression(self.regex)
        }
    }
    
    static func parse(fromLrc lrc: String) -> Lyrics {
        var lyrics = Lyrics()
        let lines = lrc.components(separatedBy: .newlines).filter({ !$0.isEmpty })
        if !Regex.allCases.map({ $0.regularExpression.isMatch(lrc) }).isEmpty {
            var metadata = LyricsMetadata()
            lines.forEach { line in
                guard let key = Regex.allCases.first(where: { $0.regularExpression.isMatch(line) }) else { return }
                
                var rawLine = line
                rawLine.removeFirst("[\(key.rawValue):".count)
                if rawLine.first == " " {
                    rawLine.removeFirst()
                }
                
                if rawLine.last == "]" {
                    rawLine.removeLast()
                }
                
                switch key {
                    case .album:
                        metadata.album = rawLine
                    case .artist:
                        metadata.artist = rawLine
                    case .comment:
                        metadata.comment = rawLine
                    case .length:
                        metadata.length = rawLine
                    case .title:
                        metadata.title = rawLine
                }
            }
            
            lyrics.metadata = metadata
        }
        
        var lyricLines = [LyricsLine]()
        lines.filter({ NSRegularExpression("\\[\\d{2}:\\d{2}.\\d{2}\\].+").isMatch($0) }).forEach { line in
            let lineStartIndex = line.startIndex
            let startIndex = line.index(lineStartIndex, offsetBy: 1)
            let endIndex = line.index(lineStartIndex, offsetBy: 8)
            let startTime = line[startIndex...endIndex]
            
            var text = line
            text.removeFirst("[00:00.00]".count)
            if text.first == " " {
                text.removeFirst()
            }
            
            var lyricLine = LyricsLine(beginTime: String(startTime))
            if NSRegularExpression("<\\d{2}:\\d{2}.\\d{2}>").isMatch(text) {
                var lyricsWords = [LyricsWord]()
                text.components(separatedBy: "<").filter({ !$0.isEmpty }).forEach { component in
                    let parts = component.components(separatedBy: ">")
                    guard parts.count == 2 else { return }
                    
                    let beginTime = parts[0]
                    let word = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let lyricsWord = LyricsWord(beginTime: beginTime, word: word)
                    lyricsWords.append(lyricsWord)
                }
                
                lyricLine.words = lyricsWords
            } else {
                lyricLine.lineWithoutTimes = text
            }
            
            lyricLines.append(lyricLine)
        }
        
        lyrics.lines = lyricLines
        return lyrics
    }
}
