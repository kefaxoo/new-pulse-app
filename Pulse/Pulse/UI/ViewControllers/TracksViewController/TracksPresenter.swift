//
//  TracksPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

protocol TracksPresenterDelegate: AnyObject {
    func reloadData()
}

final class TracksPresenter: BasePresenter {
    private var tracks = [TrackModel]()
    private var showedTracks = [TrackModel]()
    private var type: LibraryControllerType = .none
    
    private weak var delegate: TracksPresenterDelegate?
    
    var tracksCount: Int {
        return showedTracks.count
    }
    
    init(type: LibraryControllerType, delegate: TracksPresenterDelegate?) {
        self.type = type
        self.delegate = delegate
        self.fetchTracks()
    }
    
    private func fetchTracks() {
        self.tracks.removeAll()
        switch type {
            case .library:
                self.tracks = RealmManager<LibraryTrackModel>().read().map({ TrackModel($0) }).sorted
            default:
                MainCoordinator.shared.popViewController()
                return
        }
        
        self.showedTracks = self.tracks
    }
    
    func textDidChange(_ text: String) {
        if text.isEmpty {
            self.showedTracks = self.tracks
        } else {
            self.showedTracks = self.tracks.filter({ $0.title.lowercased().contains(text) || $0.artistText.lowercased().contains(text) })
        }
        
        self.delegate?.reloadData()
    }
}

// MARK: -
// MARK: Lifecycle
extension TracksPresenter {
    func viewWillAppear() {
        self.reloadData()
    }
}

// MARK: -
// MARK: Table view methods
extension TracksPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        self.setupCell(tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.id, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        (cell as? TrackTableViewCell)?.setupCell(tracks[indexPath.item], isSearchController: false, isLibraryController: self.type == .library)
        (cell as? TrackTableViewCell)?.delegate = self
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        var track = tracks[indexPath.item]
        if !track.cachedFilename.isEmpty,
           let cachedLink = AudioManager.shared.getLocalLink(for: track) {
            self.tracks[indexPath.item].playableLinks = PlayableLinkModel(cachedLink)
            track = self.tracks[indexPath.item]
            AudioPlayer.shared.play(from: track, playlist: self.tracks, position: indexPath.item)
        } else if track.playableLinks?.streamingLinkNeedsToRefresh ?? true {
            AudioManager.shared.updatePlayableLink(for: track) { [weak self] updatedTrack in
                self?.tracks[indexPath.item] = updatedTrack.track
                AudioPlayer.shared.play(from: updatedTrack.track, playlist: self?.tracks ?? [], position: indexPath.item)
            }
        } else {
            AudioPlayer.shared.play(from: track, playlist: tracks, position: indexPath.item)
        }
    }
}

// MARK: -
// MARK: TableViewCellDelegate
extension TracksPresenter: TableViewCellDelegate {
    func reloadData() {
        self.fetchTracks()
        self.delegate?.reloadData()
    }
}
