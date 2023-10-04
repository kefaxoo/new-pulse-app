//
//  SessionCacheManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.10.23.
//

import Foundation

final class SessionCacheManager {
    static let shared = SessionCacheManager()
    
    private var queue = [TrackModel]()
    private var isDownloading = false
    
    fileprivate init() {}
    
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
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    func getCacheUrl(for track: TrackModel) -> URL? {
        let filename = self.getFilename(for: track)
        return URL(filename: filename, path: .cachesDirectory)
    }
    
    func getFilename(for track: TrackModel) -> String {
        return "\(track.service.rawValue)-\(track.id)-\(track.extension)"
    }
    
    private func startCaching() {
        guard !self.queue.isEmpty else { return }
        
        
    }
    
    private func cache(_ track: TrackModel?, completion: @escaping((TrackModel?) -> ())) {
        guard let track else {
            self.isDownloading = false
            completion(nil)
            return
        }
    }
}
