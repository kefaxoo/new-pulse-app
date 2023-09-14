//
//  LibraryManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 9.09.23.
//

import Foundation
import RealmSwift

final class LibraryManager {
    static let shared = LibraryManager()
    
    fileprivate init() {}
    
    func initialSetup() {
        debugLog(URL(filename: "", path: .documentDirectory)?.absoluteString)
        
        createDirectoryIfNeeded(directory: "Covers")
        createDirectoryIfNeeded(directory: "Tracks")
        loadCoversIfNeeded()
        
        DownloadManager.shared.cacheTracksIfNeeded()
    }
    
    private func createDirectoryIfNeeded(directory: String) {
        guard let url = URL(filename: directory, path: .documentDirectory) else { return }

        let path: String
        if #available(iOS 16.0, *) {
            path = url.path()
        } else {
            path = url.path
        }
        
        guard !FileManager.default.fileExists(atPath: path) else { return }
        
        _ = try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    
    func isTrackInLibrary(_ track: TrackModel) -> Bool {
        return RealmManager<LibraryTrackModel>().read().first { libraryTrack in
            return libraryTrack.id == track.id && libraryTrack.service == track.service.rawValue
        } != nil
    }
    
    func isTrackDownloaded(_ track: TrackModel) -> Bool {
        return RealmManager<LibraryTrackModel>().read().first { [weak self] libraryTrack in
            let isTrackInLibrary = self?.isTrackInLibrary(track) ?? false
            let idsAreEqual = libraryTrack.id == track.id
            let servicesAreEqual = libraryTrack.service == track.service.rawValue
            let isTrackFilenameEmpty = libraryTrack.trackFilename.isEmpty
            let isTrackDownloading = libraryTrack.trackFilename == "downloading"
            return isTrackInLibrary && idsAreEqual && servicesAreEqual && !isTrackFilenameEmpty && !isTrackDownloading
        } != nil
    }
    
    func isTrackDownloading(_ track: TrackModel) -> Bool {
        return RealmManager<LibraryTrackModel>().read().first { [weak self] libraryTrack in
            let isTrackInLibrary = self?.isTrackInLibrary(track) ?? false
            let idsAreEqual = libraryTrack.id == track.id
            let servicesAreEqual = libraryTrack.service == track.service.rawValue
            let isTrackFilenameEmpty = libraryTrack.trackFilename.isEmpty
            let isTrackDownloading = libraryTrack.trackFilename == "downloading"
            return isTrackInLibrary && idsAreEqual && servicesAreEqual && !isTrackFilenameEmpty && isTrackDownloading
        } != nil
    }
    
    func createArtistIfNeeded(_ artist: ArtistModel?) -> Int {
        guard let artist else { return -1 }
        
        guard RealmManager<LibraryArtistModel>().read().first(where: { $0.id == artist.id }) == nil else {
            return artist.id
        }
        
        RealmManager<LibraryArtistModel>().write(object: LibraryArtistModel(artist))
        return artist.id
    }
    
    private func privateCreateArtistsIfNeeded(_ artists: [ArtistModel]) -> [Int] {
        return artists.map({ self.createArtistIfNeeded($0) })
    }
    
    func createArtistsIfNeeded(_ artists: [ArtistModel]) -> List<Int> {
        let artistIds = List<Int>()
        self.privateCreateArtistsIfNeeded(artists).forEach({ artistIds.append($0) })
        return artistIds
    }
    
    func loadCoversIfNeeded() {
        RealmManager<LibraryTrackModel>().read().forEach { track in
            guard track.coverFilename.isEmpty else { return }
            
            ImageManager.shared.saveCover(TrackModel(track)) { filename in
                guard let filename else { return }
                
                RealmManager<LibraryTrackModel>().update { realm in
                    try? realm.write {
                        track.coverFilename = filename
                    }
                }
            }
        }
    }
    
    func findLibraryArtist(id: Int) -> ArtistModel? {
        guard let artist = RealmManager<LibraryArtistModel>().read().first(where: { $0.id == id }) else { return nil }
        
        return ArtistModel(artist)
    }
    
    func removeFile(_ url: URL?) -> Bool {
        guard let url else { return false }
        
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
    
    func getCachedFilename(for track: TrackModel) -> String? {
        guard let libraryTrack = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == track.id && $0.service == track.service.rawValue }),
              !libraryTrack.trackFilename.isEmpty
        else { return nil }
        
        return libraryTrack.trackFilename
    }
}
