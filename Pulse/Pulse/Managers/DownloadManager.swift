//
//  DownloadManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import Foundation
import UIKit

final class DownloadManager {
    static let shared = DownloadManager()
    
    private let urlSession = URLSession.shared
    
    private var isDownloading = false
    private var downloadQueue: [DownloadQueueTrackModel]
    
    fileprivate init() {
        self.downloadQueue = RealmManager<DownloadQueueTrackModel>().read()
        guard !downloadQueue.isEmpty else { return }
        
        self.startDownloading()
    }
    
    func downloadImage(from link: String, completion: ((UIImage?) -> ())? = nil) {
        guard let url = URL(string: link) else {
            completion?(nil)
            return
        }
        
        urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  statusCode >= 200, statusCode < 300,
                  let data,
                  let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completion?(image)
            }
        }.resume()
    }
    
    func downloadTempTrack(_ track: TrackModel, completion: @escaping((URL?) -> ())) {
        var track = track
        let url = URL(filename: track.trackFilename, path: .documentDirectory)
        if let streamingLinkNeedsToRefresh = track.playableLinks?.streamingLinkNeedsToRefresh,
            streamingLinkNeedsToRefresh {
            AudioManager.shared.updatePlayableLink(for: track) { updatedTrack in
                track = updatedTrack.track
                self.downloadTrack(from: track.playableLinks?.streaming, to: url, completion: completion)
            } failure: {
                completion(nil)
            }
            
            return
        }
        
        self.downloadTrack(from: track.playableLinks?.streaming, to: url, completion: completion)
    }
    
    func downloadTrack(from link: String?, to directory: URL?, completion: @escaping((URL?) -> ())) {
        guard let link,
              let url = URL(string: link),
              let directory
        else {
            completion(nil)
            return
        }
        
        urlSession.dataTask(with: URLRequest(url: url), completionHandler: { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  statusCode >= 200, statusCode < 300,
                  let data
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            
            do {
                try data.write(to: directory)
                DispatchQueue.main.async {
                    completion(directory)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }).resume()
    }
    
    func cacheTracksIfNeeded() {}
}

extension DownloadManager {
    func addTrackToQueue(_ track: TrackModel, closure: @escaping(() -> ())) {
        guard !self.downloadQueue.contains(where: { $0.id == track.id && $0.service == track.service.rawValue }) else { return }
        
        let queueObj = DownloadQueueTrackModel(track)
        self.downloadQueue.append(queueObj)
        RealmManager<DownloadQueueTrackModel>().write(object: queueObj)
        self.startDownloading()
        let libraryTrack = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == track.id && $0.service == track.service.rawValue })
        RealmManager<LibraryTrackModel>().update { realm in
            try? realm.write {
                libraryTrack?.trackFilename = "downloading"
                closure()
            }
        }
    }
}

fileprivate extension DownloadManager {
    func startDownloading() {
        guard !self.downloadQueue.isEmpty else { return }
        
        self.download(self.downloadQueue.first) { [weak self] queryModel in
            if let queryModel {
                let track = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == queryModel.id && $0.service == queryModel.service })
                RealmManager<LibraryTrackModel>().update { realm in
                    try? realm.write {
                        track?.trackFilename = queryModel.filename
                    }
                }
            } else {
                if let obj = self?.downloadQueue.first {
                    let track = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == obj.id && $0.service == obj.service })
                    RealmManager<LibraryTrackModel>().update { realm in
                        try? realm.write {
                            track?.trackFilename = ""
                        }
                    }
                }
            }
            
            if let self {
                RealmManager<DownloadQueueTrackModel>().delete(object: self.downloadQueue.removeFirst())
            }
            
            self?.startDownloading()
        }
    }
    
    func download(_ obj: DownloadQueueTrackModel?, completion: @escaping((DownloadQueueTrackModel?) -> ())) {
        guard let obj,
              let source = SourceType(rawValue: obj.source),
              let service = ServiceType(rawValue: obj.service)
        else {
            self.isDownloading = false
            completion(nil)
            return
        }
        
        switch source {
            case .muffon:
                MuffonProvider.shared.trackInfo(id: obj.id, service: service) { [weak self] muffonTrack in
                    let filename = TrackModel(muffonTrack).trackFilename
                    self?.downloadTrack(from: muffonTrack.audio.link, to: URL(filename: filename, path: .documentDirectory), completion: { url in
                        guard url != nil else {
                            completion(nil)
                            return
                        }
                        
                        obj.filename = filename
                        completion(obj)
                    })
                } failure: {
                    completion(nil)
                    return
                }
            case .none:
                completion(nil)
        }
    }
}