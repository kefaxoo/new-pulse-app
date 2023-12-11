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
    
    private var isResultsLoading = false
    private var canLoadMore = true
    
    private var soundcloudCursor: String?
    
    private var didChangePlaylistInPlayer = false
    
    private weak var delegate: TracksPresenterDelegate?
    
    var tracksCount: Int {
        return showedTracks.count
    }
    
    var tracksIsEmpty: Bool {
        return showedTracks.isEmpty
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
            case .soundcloud:
                MainCoordinator.shared.currentViewController?.presentSpinner()
                SoundcloudProvider.shared.libraryTracks { [weak self] soundcloudTracks, cursor in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    let tracks = soundcloudTracks.map({ TrackModel($0) })
                    self?.tracks = tracks
                    self?.showedTracks = tracks
                    self?.soundcloudCursor = cursor
                    self?.delegate?.reloadData()
                } failure: { error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    MainCoordinator.shared.popViewController()
                    AlertView.shared.presentError(error: error?.message ?? "Unknown Soundcloud Error", system: .iOS16AppleMusic)
                }
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
    
    func index(for track: TrackModel) -> Int? {
        return self.tracks.firstIndex(where: { $0 == track })
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
        self.setupCell(tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.id), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        let track = showedTracks[indexPath.item]
        (cell as? TrackTableViewCell)?.setupCell(
            track,
            state: AudioPlayer.shared.state(for: track),
            isSearchController: false,
            isLibraryController: self.type == .library
        )
        
        (cell as? TrackTableViewCell)?.delegate = self
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let track = tracks[indexPath.item]
        if track.needFetchingPlayableLinks {
            AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                self?.tracks[indexPath.item] = updatedTrack.track
                AudioPlayer.shared.play(
                    from: updatedTrack.track,
                    playlist: self?.tracks ?? [],
                    position: indexPath.item,
                    isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false)
                )
                
                if !(self?.didChangePlaylistInPlayer ?? false) {
                    self?.didChangePlaylistInPlayer = true
                }
            }
        } else {
            AudioPlayer.shared.play(from: track, playlist: tracks, position: indexPath.item, isNewPlaylist: !self.didChangePlaylistInPlayer)
            if !self.didChangePlaylistInPlayer {
                self.didChangePlaylistInPlayer = true
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.type != .library,
              self.type != .none
        else { return }
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height,
           !isResultsLoading,
           !tracks.isEmpty,
           canLoadMore {
            self.isResultsLoading = true
            MainCoordinator.shared.currentViewController?.presentSpinner()
            switch self.type {
                case .soundcloud:
                    SoundcloudProvider.shared.libraryTracks(cursor: self.soundcloudCursor) { [weak self] tracks, cursor in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self?.soundcloudCursor = cursor
                        self?.tracks.append(contentsOf: tracks.map({ TrackModel($0) }))
                        self?.showedTracks = self?.tracks ?? []
                        self?.isResultsLoading = false
                        self?.delegate?.reloadData()
                        self?.canLoadMore = !tracks.isEmpty
                    } failure: { [weak self] _ in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self?.isResultsLoading = false
                        self?.canLoadMore = false
                    }
                default:
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self.isResultsLoading = false
                    self.canLoadMore = false
            }
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
