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
            libraryActions.append(self.removeTrackToLibrary(track))
            if !LibraryManager.shared.isTrackDownloaded(track) {
                if !LibraryManager.shared.isTrackDownloading(track) {
                    libraryActions.append(downloadTrack(track))
                }
            } else {
                
            }
        } else {
            libraryActions.append(self.addTrackToLibrary(track))
        }
        
        let libraryMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        let shareMenu = UIMenu(options: .displayInline, children: [self.shareTrackAsLink(track), self.shareTrackAsFile(track)])
        
        return UIMenu(options: .displayInline, children: [libraryMenu, shareMenu])
    }
    
    private func addTrackToLibrary(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Add to library", image: UIImage(systemName: Constants.Images.System.heartFilled)) { [weak self] _ in
            let libraryTrack = LibraryTrackModel(track)
            RealmManager<LibraryTrackModel>().write(object: libraryTrack)
            AlertView.shared.present(title: "Added to library", alertType: .done, system: .iOS17AppleMusic)
            track.image = ImageModel(coverFilename: libraryTrack.coverFilename)
            self?.delegate?.updatedTrack(track)
            self?.delegate?.updateButtonMenu()
        }
        
        return action
    }
    
    private func removeTrackToLibrary(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Remove from library", image: UIImage(systemName: Constants.Images.System.heartWithSlashFilled), attributes: .destructive) { _ in
            guard let libraryTrack = RealmManager<LibraryTrackModel>().read().first(where: { $0.id == track.id && $0.service == track.service.rawValue }) else { return }
            
            if !libraryTrack.coverFilename.isEmpty,
               RealmManager<LibraryTrackModel>().read().filter({ track.image?.contains($0.coverFilename) ?? false }).count < 2 {
                _ = LibraryManager.shared.removeFile(URL(filename: track.image?.original ?? "", path: .documentDirectory))
            }
            
            let tracks = RealmManager<LibraryTrackModel>().read().filter({ $0.artistId == (track.artist?.id ?? -1) || $0.artistIds.contains(track.artist?.id ?? -1) })
            if tracks.count < 2,
               let artist = RealmManager<LibraryArtistModel>().read().first(where: { $0.id == tracks[0].artistId }) {
                RealmManager<LibraryArtistModel>().delete(object: artist)
            }
            
            RealmManager<LibraryTrackModel>().delete(object: libraryTrack)
            self.delegate?.updateButtonMenu()
            self.delegate?.reloadData()
            AlertView.shared.present(title: "Removed to library", alertType: .done, system: .iOS17AppleMusic)
        }
        
        return action
    }
    
    private func downloadTrack(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Download track", image: UIImage(systemName: Constants.Images.System.download)) { _ in
            DownloadManager.shared.addTrackToQueue(track) { [weak self] in
                self?.delegate?.updateButtonMenu()
            }
        }
        
        return action
    }
    
    private func shareTrackAsLink(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Share track as link", image: UIImage(systemName: Constants.Images.System.share)) { _ in
            let text = "Listen to \(track.title) by \(track.artistText)\n\(track.shareLink)"
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            MainCoordinator.shared.present(activityVC, animated: true)
        }
        
        return action
    }
    
    private func shareTrackAsFile(_ track: TrackModel) -> UIAction {
        let action = UIAction(title: "Share track as file", image: UIImage(systemName: Constants.Images.System.share)) { _ in
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
