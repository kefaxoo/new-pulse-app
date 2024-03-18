//
//  NewLibraryManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.03.24.
//

import Foundation
import RealmSwift

extension Notification.Name {
    static let removeTrackFromLibrary = Notification.Name("removeTrackFromLibrary")
    static let addTrackToLibrary = Notification.Name("addTrackToLibrary")
    static let trackWasCached = Notification.Name("trackWasCached")
}

final class NewLibraryManager {
    static func appStarting() {
        debugPrint(URL(filename: "", path: .documentDirectory)?.absoluteString)
        
        self.createDirectoriesIfNeeded()
        self.loadCoversIfNeeded()
        
        DownloadManager.shared.cacheTracksIfNeeded()
        
        self.syncTracksIfNeeded()
    }
}

// MARK: -
// MARK: Track
extension NewLibraryManager {
    static func likeTrack(_ track: TrackModel) {
        DispatchQueue.main.async {
            let libraryTrack = LibraryTrackModel(track)
            RealmManager<LibraryTrackModel>().write(object: libraryTrack)
        }
        
        switch track.service {
            case .soundcloud:
                guard SettingsManager.shared.soundcloud.isSigned,
                      SettingsManager.shared.soundcloudLike
                else { break }
                
                SoundcloudProvider.shared.likeTrack(id: track.id)
            case .yandexMusic:
                guard SettingsManager.shared.yandexMusic.isSigned,
                      SettingsManager.shared.yandexMusicLike
                else { break }
                
                YandexMusicProvider.shared.likeTrack(track)
            default:
                break
        }
        
        AlertView.shared.present(title: "Added to library", alertType: .done, system: .iOS17AppleMusic)
        
        NotificationCenter.default.post(name: .addTrackToLibrary, object: nil, userInfo: [
            "track": track,
            "state": TrackLibraryState.added
        ])
        
        PulseProvider.shared.likeTrack(track)
        
        if SettingsManager.shared.autoDownload {
            DownloadManager.shared.addTrackToQueue(track) {
                NotificationCenter.default.post(name: .trackWasCached, object: nil, userInfo: [
                    "track": track,
                    "state": TrackLibraryState.downloaded
                ])
            }
        }
    }
    
    static func dislikeTrack(_ track: TrackModel) {
        DispatchQueue.main.async {
            guard let libraryTrack = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == track.id && $0.service == track.service.rawValue && $0.source == track.source.rawValue }) else { return }
            
            if !libraryTrack.coverFilename.isEmpty,
               RealmManager<LibraryTrackModel>().read().filter({ track.image?.contains($0.coverFilename) ?? false }).count < 2,
               self.removeFile(at: URL(filename: libraryTrack.trackFilename, path: .documentDirectory)) {
                RealmManager<LibraryTrackModel>().update { realm in
                    try? realm.write {
                        libraryTrack.trackFilename = ""
                    }
                }
            }
            
            let tracks = RealmManager<LibraryTrackModel>().read().filter({ $0.artistId == (track.artist?.id ?? -1) || $0.artistIds.contains(track.artist?.id ?? -1) })
            if tracks.count < 2,
               let artist = RealmManager<LibraryArtistModel>().read().first(where: { $0.id == tracks.first?.artistId }) {
                RealmManager<LibraryArtistModel>().delete(object: artist)
            }
            
            RealmManager<LibraryTrackModel>().delete(object: libraryTrack)
        }
        
        switch track.service {
            case .soundcloud:
                guard SettingsManager.shared.soundcloud.isSigned,
                      SettingsManager.shared.soundcloudLike
                else { break }
                
                SoundcloudProvider.shared.removeLikeTrack(id: track.id)
            case .yandexMusic:
                guard SettingsManager.shared.yandexMusic.isSigned,
                      SettingsManager.shared.yandexMusicLike
                else { break }
                
                YandexMusicProvider.shared.removeLikeTrack(track)
            default:
                break
        }
        
        AlertView.shared.present(title: "Removed from library", alertType: .done, system: .iOS17AppleMusic)
        
        NotificationCenter.default.post(name: .removeTrackFromLibrary, object: nil, userInfo: [
            "track": track,
            "state": TrackLibraryState.none
        ])
        
        PulseProvider.shared.dislikeTrack(track)
    }
    
    static func getCachedFilename(for track: TrackModel) -> String? {
        return RealmManager<LibraryTrackModel>().read().first(where: { $0.id == track.id && $0.service == track.service.rawValue && $0.source == track.source.rawValue })?.trackFilename
    }
    
    static func isTrackInLibrary(_ track: TrackModel) -> Bool {
        return RealmManager<LibraryTrackModel>().read().first(where: { return $0.id == track.id && $0.service == track.service.rawValue && $0.source == track.source.rawValue }) != nil
    }
    
    static func isTrackDownloaded(_ track: TrackModel) -> Bool {
        return RealmManager<LibraryTrackModel>().read().first(where: {
            return self.isTrackInLibrary(track) && !$0.trackFilename.isEmpty && $0.trackFilename != "downloading"
        }) != nil
    }
    
    static func isTrackDownloading(_ track: TrackModel) -> Bool {
        return RealmManager<LibraryTrackModel>().read().first(where: {
            return self.isTrackInLibrary(track) && !$0.trackFilename.isEmpty && $0.trackFilename == "downloading"
        }) != nil
    }
}

// MARK: -
// MARK: File actions
extension NewLibraryManager {
    @discardableResult static func removeFile(at url: URL?) -> Bool {
        guard let url else { return false }
        
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}

// MARK: -
// MARK: Temporary cache
extension NewLibraryManager {
    static func removeTemporaryCache() {
        guard let url = URL(filename: "", path: .cachesDirectory) else { return }
        
        let path: String
        if #available(iOS 16.0, *) {
            path = url.path()
        } else {
            path = url.path
        }
        
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: path) else { return }
        
        items.forEach({
            guard let url = URL(filename: $0, path: .cachesDirectory),
                  !url.isDirectory || $0.contains("SDImageCache")
            else { return }
            
            Self.removeFile(at: url)
        })
    }
}

// MARK: -
// MARK: Library
extension NewLibraryManager {
    @discardableResult static func cleanLibrary() -> Bool {
        LibraryManager.shared.removeFile(URL(filename: "Covers", path: .documentDirectory))
        LibraryManager.shared.removeFile(URL(filename: "Tracks", path: .documentDirectory))
        self.removeTemporaryCache()
        
        RealmManager<LibraryTrackModel>().removeAll()
        RealmManager<LibraryArtistModel>().removeAll()
        RealmManager<DownloadQueueTrackModel>().removeAll()
        
        return true
    }
    
    static func syncTracksIfNeeded() {
        PulseProvider.shared.syncTracks()
    }
    
    static func loadCoversIfNeeded() {
        RealmManager<LibraryTrackModel>().read().forEach { track in
            guard track.coverFilename.isEmpty else { return }
            
            ImageManager.shared.saveCover(TrackModel(track)) { [track] filename in
                guard let filename else { return }
                
                RealmManager<LibraryTrackModel>().update { realm in
                    try? realm.write {
                        track.coverFilename = filename
                    }
                }
            }
        }
    }
    
    static func createDirectoriesIfNeeded() {
        self.createDirectoryIfNeeded(directory: "Covers", path: .documentDirectory)
        self.createDirectoryIfNeeded(directory: "Tracks", path: .documentDirectory)
    }
    
    @discardableResult static func createDirectoryIfNeeded(directory: String, path: FileManager.SearchPathDirectory) -> Bool {
        guard let url = URL(filename: directory, path: path) else { return false }
        
        let path: String
        if #available(iOS 16.0, *) {
            path = url.path()
        } else {
            path = url.path
        }
        
        guard !FileManager.default.fileExists(atPath: path) else { return false }
        
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
}

// MARK: -
// MARK: Artist
extension NewLibraryManager {
    static func findLibraryArtist(for id: Int) -> ArtistModel? {
        guard let artist = RealmManager<LibraryArtistModel>().read().first(where: { $0.id == id }) else { return nil }
        
        return ArtistModel(artist)
    }
    
    static func createArtistIfNeeded(_ artist: ArtistModel?) -> Int {
        guard let artist else { return -1 }
        
        guard self.findLibraryArtist(for: artist.id) == nil else { return artist.id }
        
        RealmManager<LibraryArtistModel>().write(object: LibraryArtistModel(artist))
        return artist.id
    }
    
    static func createArtistsIfNeeded(_ artists: [ArtistModel]) -> List<Int> {
        let artistsIds = List<Int>()
        artists.forEach({ artistsIds.append(self.createArtistIfNeeded($0)) })
        return artistsIds
    }
}
