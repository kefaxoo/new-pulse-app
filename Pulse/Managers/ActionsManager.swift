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
    func removeTrack(_ track: TrackModel)
}

extension ActionsManagerDelegate {
    func updateButtonMenu() {}
    func updatedTrack(_ track: TrackModel) {}
    func reloadData() {}
    func updateTrackState(_ state: TrackLibraryState) {}
    func removeTrack(_ track: TrackModel) {}
}

final class ActionsManager {
    private weak var delegate: ActionsManagerDelegate?
    
    init(_ delegate: ActionsManagerDelegate?) {
        self.delegate = delegate
    }
    
    func trackActions(for track: TrackModel, completion: @escaping((UIMenu?) -> ())) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let manager = self ?? Self(nil)
            completion(manager.trackActions(track))
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
        let action = UIAction(title: "Add to library", image: Constants.Images.inLibrary.image) { _ in
            NewLibraryManager.likeTrack(track)
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
            AlertView.shared.present(title: "Removed from library", alertType: .done, system: .iOS17AppleMusic)
            
            PulseProvider.shared.dislikeTrack(track)
            
            switch track.service {
                case .yandexMusic:
                    guard SettingsManager.shared.settings.yandexMusicLike else { return }
                    
                    YandexMusicProvider.shared.removeLikeTrack(track)
                case .soundcloud:
                    guard SettingsManager.shared.soundcloudLike else { break }
                    
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

// MARK: -
// MARK: UIContextualAction methods
extension ActionsManager {
    enum SwipeDirection {
        case leadingToTrailing
        case trailingToLeading
    }
    
    func trackSwipeActionsConfiguration(for track: TrackModel, swipeDirection direction: SwipeDirection) -> UISwipeActionsConfiguration {
        switch direction {
            case .leadingToTrailing:
                return UISwipeActionsConfiguration(actions: [self.playNextContextual(track), self.playLastContextual(track)])
            case .trailingToLeading:
                if LibraryManager.shared.isTrackInLibrary(track) {
                    var actions = [self.removeFromLibraryContextual(track)]
                    if !LibraryManager.shared.isTrackDownloaded(track) {
                        actions.append(self.downloadTrackContextual(track))
                    }
                    
                    return UISwipeActionsConfiguration(actions: actions)
                } else {
                    return UISwipeActionsConfiguration(actions: [self.addToLibraryContextual(track)])
                }
        }
    }
}

private extension ActionsManager {
    func playNextContextual(_ track: TrackModel) -> UIContextualAction {
        let playNextAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            if SessionCacheManager.shared.isTrackInCache(track) || track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
                AudioManager.shared.getPlayableLink(for: track) { updatedTrack in
                    AudioPlayer.shared.playNext(updatedTrack.track)
                }
            } else {
                AudioPlayer.shared.playNext(track)
            }
            
            completion(true)
        }
        
        playNextAction.image = Constants.Images.playNext.image
        playNextAction.backgroundColor = UIColor(hex: "#5D5CE6")
        return playNextAction
    }
    
    func playLastContextual(_ track: TrackModel) -> UIContextualAction {
        let playLastAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            if SessionCacheManager.shared.isTrackInCache(track) || track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
                AudioManager.shared.getPlayableLink(for: track) { updatedTrack in
                    AudioPlayer.shared.playLast(updatedTrack.track)
                }
            } else {
                AudioPlayer.shared.playLast(track)
            }
            
            completion(true)
        }
        
        playLastAction.image = Constants.Images.playLast.image
        playLastAction.backgroundColor = UIColor(hex: "#FE9F0C")
        return playLastAction
    }
    
    func addToLibraryContextual(_ track: TrackModel) -> UIContextualAction {
        let addToLibraryAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
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
                track.image = ImageModel(libraryTrack.coverFilename)
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
                        if SettingsManager.shared.yandexMusicLike,
                           SettingsManager.shared.yandexMusic.isSigned {
                            YandexMusicProvider.shared.likeTrack(track)
                        }
                    default:
                        break
                }
                
                guard SettingsManager.shared.autoDownload else { return }
                
                DownloadManager.shared.addTrackToQueue(track) {
                    NotificationCenter.default.post(name: .updateLibraryState, object: nil, userInfo: [
                        "track": track,
                        "state": TrackLibraryState.added
                    ])
                }
            }
            
            completion(true)
        }
        
        addToLibraryAction.image = Constants.Images.inLibrary.image
        addToLibraryAction.backgroundColor = SettingsManager.shared.color.color
        return addToLibraryAction
    }
    
    func removeFromLibraryContextual(_ track: TrackModel) -> UIContextualAction {
        let removeFromLibraryAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            completion(true)
            guard let libraryTrack = RealmManager<LibraryTrackModel>().read()
                .first(where: { $0.id == track.id && $0.service == track.service.rawValue })
            else { return }
            
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
            
            let tracks = RealmManager<LibraryTrackModel>().read()
                .filter({ $0.artistId == (track.artist?.id ?? -1) || $0.artistIds.contains(track.artist?.id ?? -1) })
            
            if tracks.count < 2,
               let artist = RealmManager<LibraryArtistModel>().read().first(where: { $0.id == tracks[0].artistId }) {
                RealmManager<LibraryArtistModel>().delete(object: artist)
            }
            
            RealmManager<LibraryTrackModel>().delete(object: libraryTrack)
            AudioPlayer.shared.setupTrackNowPlayingCommands()
            AlertView.shared.present(title: "Removed from library", alertType: .done, system: .iOS17AppleMusic)
            
            PulseProvider.shared.dislikeTrack(track)
            
            switch track.service {
                case .yandexMusic:
                    guard SettingsManager.shared.yandexMusicLike,
                          SettingsManager.shared.yandexMusic.isSigned
                    else { break }
                    
                    YandexMusicProvider.shared.removeLikeTrack(track)
                case .soundcloud:
                    guard SettingsManager.shared.soundcloudLike,
                          SettingsManager.shared.soundcloud.isSigned
                    else { break }
                    
                    SoundcloudProvider.shared.removeLikeTrack(id: track.id)
                default:
                    break
            }
            
            self?.delegate?.removeTrack(track)
            NotificationCenter.default.post(name: .updateLibraryState, object: nil, userInfo: [
                "track": track,
                "state": TrackLibraryState.none
            ])
        }
        
        removeFromLibraryAction.image = Constants.Images.removeFromLibrary.image
        return removeFromLibraryAction
    }
    
    func downloadTrackContextual(_ track: TrackModel) -> UIContextualAction {
        let downloadTrackAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            completion(true)
            DownloadManager.shared.addTrackToQueue(track) {
                NotificationCenter.default.post(name: .updateLibraryState, object: nil, userInfo: [
                    "track": track,
                    "state": TrackLibraryState.downloaded
                ])
            }
        }
        
        downloadTrackAction.image = Constants.Images.download.image
        downloadTrackAction.backgroundColor = UIColor(hex: "#0B84FE")
        return downloadTrackAction
    }
}
