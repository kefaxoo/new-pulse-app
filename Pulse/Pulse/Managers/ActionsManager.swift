//
//  ActionsManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 9.09.23.
//

import UIKit

protocol ActionsManagerDelegate: AnyObject {
    func updateButtonMenu()
    func updatedTrack(_ track: TrackModel)
    func reloadData()
}

extension ActionsManagerDelegate {
    func reloadData() {}
}

final class ActionsManager {
    private weak var delegate: ActionsManagerDelegate?
    
    init(_ delegate: ActionsManagerDelegate?) {
        self.delegate = delegate
    }
    
    func trackActions(_ track: TrackModel) -> UIMenu {
        var libraryActions = [UIAction]()
        if LibraryManager.shared.isTrackInLibrary(track) {
            libraryActions.append(self.removeTrackFromLibrary(track))
            if !LibraryManager.shared.isTrackDownloaded(track) {
                if !LibraryManager.shared.isTrackDownloading(track) {
                    libraryActions.append(self.downloadTrack(track))
                }
            } else {
                libraryActions.append(self.removeCacheFromLibrary(track))
            }
        } else {
            libraryActions.append(self.addTrackToLibrary(track))
        }
        
        let libraryMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        let playerMenu = UIMenu(options: .displayInline, children: [self.playNext(track), self.playLast(track)])
        
        let shareMenu = UIMenu(options: .displayInline, children: [self.shareTrackAsLink(track), self.shareTrackAsFile(track)])
        
        return UIMenu(options: .displayInline, children: [libraryMenu, playerMenu, shareMenu])
    }
    
    private func addTrackToLibrary(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Add to library", image: Constants.Images.inLibrary.image) { [weak self] _ in
            AudioManager.shared.updatePlayableLink(for: track) { updatedTrack in
                let track = updatedTrack.track
                guard track.isAvailable else {
                    AlertView.shared.presentError(error: "Unavailable to add", system: .iOS16AppleMusic)
                    return
                }
                
                let libraryTrack = LibraryTrackModel(track)
                RealmManager<LibraryTrackModel>().write(object: libraryTrack)
                AlertView.shared.present(title: "Added to library", alertType: .done, system: .iOS17AppleMusic)
                track.image = ImageModel(coverFilename: libraryTrack.coverFilename)
                self?.delegate?.updatedTrack(track)
                self?.delegate?.updateButtonMenu()
                
                LibraryManager.shared.syncTrack(track)
                
                guard SettingsManager.shared.autoDownload else { return }
                
                DownloadManager.shared.addTrackToQueue(track) {
                    self?.delegate?.updateButtonMenu()
                }
            }
        }
        
        return action
    }
    
    private func removeTrackFromLibrary(_ track: TrackModel) -> UIAction {
        let action = UIAction(
            title: "Remove from library",
            image: Constants.Images.removeFromLibrary.image,
            attributes: .destructive
        ) { _ in
            guard let libraryTrack = RealmManager<LibraryTrackModel>().read().first(where: {
                $0.id == track.id && $0.service == track.service.rawValue
            }) else { return }
            
            if !libraryTrack.coverFilename.isEmpty,
               RealmManager<LibraryTrackModel>().read().filter({ track.image?.contains($0.coverFilename) ?? false }).count < 2 {
                _ = LibraryManager.shared.removeFile(URL(filename: libraryTrack.coverFilename, path: .documentDirectory))
            }
            
            if !libraryTrack.trackFilename.isEmpty {
                _ = LibraryManager.shared.removeFile(URL(filename: libraryTrack.trackFilename, path: .documentDirectory))
                
                RealmManager<LibraryTrackModel>().update { realm in
                    try? realm.write {
                        libraryTrack.trackFilename = ""
                    }
                }
            }
            
            let tracks = RealmManager<LibraryTrackModel>().read().filter({
                $0.artistId == (track.artist?.id ?? -1) || $0.artistIds.contains(track.artist?.id ?? -1)
            })
            
            if tracks.count < 2,
               let artist = RealmManager<LibraryArtistModel>().read().first(where: { $0.id == tracks[0].artistId }) {
                RealmManager<LibraryArtistModel>().delete(object: artist)
            }
            
            RealmManager<LibraryTrackModel>().delete(object: libraryTrack)
            self.delegate?.updateButtonMenu()
            self.delegate?.reloadData()
            AlertView.shared.present(title: "Removed to library", alertType: .done, system: .iOS17AppleMusic)
            
            LibraryManager.shared.removeTrack(track)
        }
        
        return action
    }
    
    private func downloadTrack(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Download track", image: Constants.Images.download.image) { _ in
            DownloadManager.shared.addTrackToQueue(track) { [weak self] in
                self?.delegate?.updateButtonMenu()
            }
        }
        
        return action
    }
    
    private func removeCacheFromLibrary(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Remove cache", image: Constants.Images.removeBin.image, attributes: .destructive) { _ in
            if let track = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == track.id && $0.service == track.service.rawValue }),
               LibraryManager.shared.removeFile(URL(filename: track.trackFilename, path: .documentDirectory)) {
                RealmManager<LibraryTrackModel>().update { realm in
                    try? realm.write {
                        track.trackFilename = ""
                    }
                }
                
                AlertView.shared.present(title: "Removed cache", alertType: .done, system: .iOS16AppleMusic)
                self.delegate?.reloadData()
                self.delegate?.updateButtonMenu()
            }
        }
        
        return action
    }
    
    private func shareTrackAsLink(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Share track as link", image: Constants.Images.share.image) { _ in
            let text = "Listen to \(track.title) by \(track.artistText)\n\(track.shareLink)"
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            MainCoordinator.shared.present(activityVC, animated: true)
        }
        
        return action
    }
    
    private func shareTrackAsFile(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Share track as file", image: Constants.Images.share.image) { _ in
            MainCoordinator.shared.currentViewController?.presentSpinner()
            DownloadManager.shared.downloadTempTrack(track) { url in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                guard let url else { return }
                
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityVC.completionWithItemsHandler = { _, _, _, _ in
                    _ = try? FileManager.default.removeItem(at: url)
                }
                
                MainCoordinator.shared.present(activityVC, animated: true)
            }
        }
        
        return action
    }
}

// MARK: -
// MARK: Player actions
fileprivate extension ActionsManager {
    func playNext(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Play next", image: Constants.Images.playNext.image) { _ in
            if track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
                AudioManager.shared.updatePlayableLink(for: track) { updatedTrack in
                    AudioPlayer.shared.playNext(updatedTrack.track)
                }
                
                return
            }
            
            AudioPlayer.shared.playNext(track)
        }
        
        return action
    }
    
    func playLast(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Play last", image: Constants.Images.playLast.image) { _ in
            if track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
                AudioManager.shared.updatePlayableLink(for: track) { updatedTrack in
                    AudioPlayer.shared.playLast(updatedTrack.track)
                }
                
                return
            }
            
            AudioPlayer.shared.playLast(track)
        }
        
        return action
    }
}
