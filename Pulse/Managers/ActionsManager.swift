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
    func updateTrackState(_ state: TrackLibraryState)
}

extension ActionsManagerDelegate {
    func updateButtonMenu() {}
    func updatedTrack(_ track: TrackModel) {}
    func reloadData() {}
    func updateTrackState(_ state: TrackLibraryState) {}
}

final class ActionsManager {
    private weak var delegate: ActionsManagerDelegate?
    
    init(_ delegate: ActionsManagerDelegate?) {
        self.delegate = delegate
    }
    
    func trackActions(for track: TrackModel, completion: @escaping((UIMenu?) -> ())) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            completion(self?.trackActions(track))
        }
    }
    
    func trackActions(_ track: TrackModel, shouldReverseActions: Bool = false) -> UIMenu {
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
        
        if shouldReverseActions {
            libraryActions = libraryActions.reversed()
        }
        
        let libraryMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        var playerActions = [self.playNext(track), self.playLast(track)]
        
        if shouldReverseActions {
            playerActions = playerActions.reversed()
        }
        
        let playerMenu = UIMenu(options: .displayInline, children: playerActions)
        
        var shareActions = [UIAction]()
        if track.service != .pulse {
            shareActions = [self.shareTrackAsLink(track), self.shareTrackAsFile(track), self.openInService(track)]
        } else {
            if track.spotifyId != nil || track.yandexMusicId != nil {
                shareActions = [self.shareTrackAsLink(track)]
            }
            
            shareActions.append(self.shareTrackAsFile(track))
            
            if track.spotifyId != nil || track.yandexMusicId != nil {
                shareActions.append(self.openInService(track))
            }
        }
        
        if shouldReverseActions {
            shareActions = shareActions.reversed()
        }
        
        let shareMenu = UIMenu(options: .displayInline, children: shareActions)
        
        var actions = [libraryMenu, playerMenu, shareMenu]
        if shouldReverseActions {
            actions = actions.reversed()
        }
        
        return UIMenu(options: .displayInline, children: actions)
    }
    
    func artistNowPlayingActions(_ artist: ArtistModel) -> UIMenu {
        return UIMenu(options: .displayInline)
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
                AudioPlayer.shared.setupTrackNowPlayingCommands()
                AlertView.shared.present(title: "Added to library", alertType: .done, system: .iOS17AppleMusic)
                track.image = ImageModel(coverFilename: libraryTrack.coverFilename)
                self?.delegate?.updateButtonMenu()
                self?.delegate?.updatedTrack(track)
                self?.delegate?.updateTrackState(.added)
                NotificationCenter.default.post(name: .updateLibraryState, object: nil, userInfo: [
                    "track": track,
                    "state": TrackLibraryState.added
                ])
                
                PulseProvider.shared.likeTrack(track)
                
                switch track.service {
                    case .soundcloud:
                        if SettingsManager.shared.soundcloudLike,
                           SettingsManager.shared.soundcloud.isSigned {
                            SoundcloudProvider.shared.likeTrack(id: track.id)
                        }
                    case .yandexMusic:
                        if SettingsManager.shared.settings.yandexMusicLike,
                           SettingsManager.shared.yandexMusic.isSigned {
                            YandexMusicProvider.shared.likeTrack(track)
                        }
                    default:
                        break
                }
                
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
                LibraryManager.shared.removeFile(URL(filename: libraryTrack.coverFilename, path: .documentDirectory))
            }
            
            if !libraryTrack.trackFilename.isEmpty {
                LibraryManager.shared.removeFile(URL(filename: libraryTrack.trackFilename, path: .documentDirectory))
                
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
            self.delegate?.updateTrackState(.none)
            self.delegate?.reloadData()
            AudioPlayer.shared.setupTrackNowPlayingCommands()
            AlertView.shared.present(title: "Removed to library", alertType: .done, system: .iOS17AppleMusic)
            
            PulseProvider.shared.dislikeTrack(track)
            
            switch track.service {
                case .yandexMusic:
                    guard SettingsManager.shared.settings.yandexMusicLike else { return }
                    
                    YandexMusicProvider.shared.removeLikeTrack(track)
                case .soundcloud:
                    guard SettingsManager.shared.soundcloudLike else { return }
                    
                    SoundcloudProvider.shared.removeLikeTrack(id: track.id)
                default:
                    break
            }
            
            NotificationCenter.default.post(name: .updateLibraryState, object: nil, userInfo: [
                "track": track,
                "state": TrackLibraryState.none
            ])
        }
        
        return action
    }
    
    private func downloadTrack(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: Localization.Actions.Title.downloadTrack.localization, image: Constants.Images.download.image) { _ in
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
                self.delegate?.updateTrackState(.added)
            }
        }
        
        return action
    }
    
    private func shareTrackAsLink(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: Localization.Actions.Title.shareTrackAsLink.localization, image: Constants.Images.share.image) { _ in
            let text = Localization.Actions.ShareTrackAsLink.shareText.localization(with: track.title, track.artistText, track.shareLink)
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            MainCoordinator.shared.present(activityVC, animated: true)
        }
        
        return action
    }
    
    private func shareTrackAsFile(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: Localization.Actions.Title.shareTrackAsFile.localization, image: Constants.Images.share.image) { _ in
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
    
    private func openInService(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: Localization.Actions.Title.openIn.localization, image: Constants.Images.openIn.image) { _ in
            MainCoordinator.shared.presentOpenInServiceViewController(track: track)
        }
        
        return action
    }
}

// MARK: -
// MARK: Player actions
fileprivate extension ActionsManager {
    func playNext(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: Localization.Actions.Title.playNext.localization, image: Constants.Images.playNext.image) { _ in
            if SessionCacheManager.shared.isTrackInCache(track) || track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
                AudioManager.shared.getPlayableLink(for: track) { updatedTrack in
                    AudioPlayer.shared.playNext(updatedTrack.track)
                }
                
                return
            }
            
            AudioPlayer.shared.playNext(track)
        }
        
        return action
    }
    
    func playLast(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: Localization.Actions.Title.playLast.localization, image: Constants.Images.playLast.image) { _ in
            if SessionCacheManager.shared.isTrackInCache(track) || track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
                AudioManager.shared.getPlayableLink(for: track) { updatedTrack in
                    AudioPlayer.shared.playLast(updatedTrack.track)
                }
                
                return
            }
            
            AudioPlayer.shared.playLast(track)
        }
        
        return action
    }
}
