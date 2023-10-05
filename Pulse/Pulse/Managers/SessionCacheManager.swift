//
//  SessionCacheManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.10.23.
//

import Foundation

fileprivate struct CachedTrackModel {
    let track: TrackModel
    var listeningCount: Int = 0
    let url: URL
    
    mutating func incrementListeningCount() {
        self.listeningCount += 1
    }
}

fileprivate struct ArrayCachedTrackModelStoredVariables {
    static var itemLimit = 0
}

fileprivate extension [CachedTrackModel] {
    var itemLimit: Int {
        get {
            return ArrayCachedTrackModelStoredVariables.itemLimit
        }
        set {
            ArrayCachedTrackModelStoredVariables.itemLimit = newValue
        }
    }
    
    mutating func append(track: TrackModel, url: URL) {
        if self.count == self.itemLimit - 1 {
            var minTrack = self[0]
            self.forEach({ minTrack = minTrack.listeningCount > $0.listeningCount ? $0 : minTrack })
            DispatchQueue.main.async {
                _ = SessionCacheManager.shared.cleanTrack(minTrack)
            }
        }
        
        self.append(CachedTrackModel(track: track, url: url))
    }
    
    mutating func incrementListeningCount(for track: TrackModel) {
        guard let index = self.firstIndex(where: { $0.track == track }) else { return }
        
        self[index].incrementListeningCount()
    }
}

final class SessionCacheManager {
    static let shared = SessionCacheManager()
    
    private var queue = [TrackModel]()
    private var isDownloading = false
    
    private var cachedTracks = [CachedTrackModel]()
    
    fileprivate init() {
        cachedTracks.itemLimit = 20
        debugPrint(URL(filename: "", path: .cachesDirectory)?.absoluteString ?? "")
    }
    
    func addTrackToQueue(_ track: TrackModel) {
        guard !self.isTrackInCache(track) else { return }
        
        self.queue.append(track)
        self.startCaching()
    }
    
    func isTrackInCache(_ track: TrackModel) -> Bool {
        guard let url = self.getCacheUrl(for: track) else { return false }
        
        let path: String
        if #available(iOS 16.0, *) {
            path = url.path()
        } else {
            path = url.path
        }
        
        let isExist = FileManager.default.fileExists(atPath: path)
        if isExist {
            self.incrementListeningCount(for: track)
        }
        
        return isExist
    }
    
    func getCacheUrl(for track: TrackModel) -> URL? {
        return URL(filename: self.getFilename(for: track), path: .cachesDirectory)
    }
    
    func getCacheLink(for track: TrackModel) -> String? {
        return self.getCacheUrl(for: track)?.absoluteString
    }
    
    func getFilename(for track: TrackModel) -> String {
        return "\(track.service.rawValue)-\(track.id).\(track.extension)"
    }
    
    private func startCaching() {
        guard !self.queue.isEmpty else { return }
        
        let track = self.queue.removeFirst()
        AudioManager.shared.updatePlayableLink(for: track) { [weak self] updatedTrack in
            guard let downloadLink = updatedTrack.track.playableLinks?.streaming else {
                self?.startCaching()
                return
            }
            
            DownloadManager.shared.downloadTrack(from: downloadLink, to: self?.getCacheUrl(for: track)) { url in
                guard let url else {
                    self?.startCaching()
                    return
                }
                
                self?.cachedTracks.append(track: updatedTrack.track, url: url)
            }
        } failure: { [weak self] in
            self?.startCaching()
        }
    }
    
    fileprivate func cleanTrack(_ track: CachedTrackModel) -> Bool {
        guard let index = self.cachedTracks.firstIndex(where: { $0.track == track.track }) else { return false }
            
        self.cachedTracks.remove(at: index)
        return LibraryManager.shared.removeFile(track.url)
    }
    
    func cleanAllCache() {
        self.cachedTracks.forEach({ _ = self.cleanTrack($0) })
    }
    
    var freeCountOfCache: Int {
        return self.cachedTracks.itemLimit - self.queue.count - self.cachedTracks.count
    }
    
    func incrementListeningCount(for track: TrackModel) {
        self.cachedTracks.incrementListeningCount(for: track)
    }
}
