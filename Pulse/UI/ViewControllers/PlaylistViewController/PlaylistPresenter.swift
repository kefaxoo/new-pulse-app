//
//  PlaylistPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import UIKit

protocol PlaylistPresenterDelegate: AnyObject {
    func reloadData()
    func changeNavigationTitleAlpha(_ alpha: CGFloat)
}

final class PlaylistPresenter: BasePresenter {
    private let playlist: PlaylistModel
    private let type: LibraryControllerType
    private var tracks = [TrackModel]()
    
    private var soundcloudOffset: String?
    
    private var isResultsLoading = false
    private var canLoadMore = true
    
    private var didChangePlaylistInPlayer = false
    
    weak var delegate: PlaylistPresenterDelegate?
    
    var tracksCount: Int {
        return self.tracks.count
    }
    
    init(_ playlist: PlaylistModel, type: LibraryControllerType) {
        self.playlist = playlist
        self.type = type
        self.fetchTracks()
    }
    
    private func fetchTracks() {
        self.tracks.removeAll()
        switch self.type {
            case .soundcloud:
                guard let id = Int(self.playlist.id) else { break }
                
                MainCoordinator.shared.currentViewController?.presentSpinner()
                SoundcloudProvider.shared.playlistTracks(id: id) { [weak self] tracks, offset in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self?.tracks = tracks.map({ TrackModel($0) })
                    self?.soundcloudOffset = offset
                    self?.delegate?.reloadData()
                } failure: { error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    MainCoordinator.shared.popViewController()
                    AlertView.shared.presentError(error: error?.message ?? "Unknown Soundcloud Error", system: .iOS16AppleMusic)
                }
            default:
                break
        }
    }
    
    func index(for track: TrackModel) -> Int? {
        return self.tracks.firstIndex(where: { $0 == track })
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension PlaylistPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let id = TrackTableViewCell.id
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: id), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        let track = self.tracks[index]
        (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track))
        (cell as? TrackTableViewCell)?.delegate = self
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let index = indexPath.item
        let track = tracks[index]
        if track.needFetchingPlayableLinks {
            AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                self?.tracks[index] = updatedTrack.track
                AudioPlayer.shared.play(
                    from: updatedTrack.track,
                    playlist: self?.tracks ?? [],
                    position: index,
                    isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false)
                )
                
                if !(self?.didChangePlaylistInPlayer ?? false) {
                    self?.didChangePlaylistInPlayer = true
                }
            }
        } else {
            AudioPlayer.shared.play(from: track, playlist: self.tracks, position: index, isNewPlaylist: !self.didChangePlaylistInPlayer)
            if !self.didChangePlaylistInPlayer {
                self.didChangePlaylistInPlayer = true
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.type != .library,
              self.type != .none
        else { return }
        
        if let headerView = (scrollView as? UITableView)?.tableHeaderView as? PlaylistTableHeaderView,
           let heightOfNavigationBar = (MainCoordinator.shared.currentViewController as? UINavigationController)?.navigationBar.bounds.height {
            let contentOffsetY = scrollView.contentOffset.y + heightOfNavigationBar
            let headerTitleMaxY = headerView.titleLabel.frame.maxY
            
            var alpha = contentOffsetY / headerTitleMaxY
            if alpha > 1 {
                alpha = 1
            } else if alpha < 0 {
                alpha = 0
            }
            
            self.delegate?.changeNavigationTitleAlpha(alpha)
        }
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height,
           !isResultsLoading,
           !tracks.isEmpty,
           canLoadMore {
            self.isResultsLoading = true
            MainCoordinator.shared.currentViewController?.presentSpinner()
            switch self.type {
                case .soundcloud:
                    guard let id = Int(self.playlist.id) else {
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        return
                    }
                    
                    SoundcloudProvider.shared.playlistTracks(id: id, offset: self.soundcloudOffset) { [weak self] tracks, offset in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self?.tracks.append(contentsOf: tracks.map({ TrackModel($0) }))
                        self?.soundcloudOffset = offset
                        self?.isResultsLoading = false
                        self?.delegate?.reloadData()
                        self?.canLoadMore = offset != nil
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
extension PlaylistPresenter: TableViewCellDelegate {
    func reloadData() {
        self.delegate?.reloadData()
    }
}
