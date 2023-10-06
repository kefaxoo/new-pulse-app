//
//  PlaylistPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import UIKit

protocol PlaylistPresenterDelegate: AnyObject {
    func reloadData()
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
}

// MARK: -
// MARK: BaseTableViewPresenter
extension PlaylistPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let id = indexPath.item == 0 ? PlaylistHeaderTableViewCell.id : TrackTableViewCell.id
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: id, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            (cell as? PlaylistHeaderTableViewCell)?.setupCell(self.playlist)
        } else {
            let index = indexPath.item - 1
            let track = self.tracks[index]
            (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track))
            (cell as? TrackTableViewCell)?.delegate = self
        }
        
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard indexPath.item > 0 else { return }
        
        let index = indexPath.item - 1
        let track = tracks[index]
        if track.needFetchingPlayableLinks {
            AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                self?.tracks[index] = updatedTrack.track
                AudioPlayer.shared.play(from: updatedTrack.track, playlist: self?.tracks ?? [], position: index, isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false))
                if !(self?.didChangePlaylistInPlayer ?? false) {
                    self?.didChangePlaylistInPlayer = true
                }
            }
        } else {
            AudioPlayer.shared.play(from: track, playlist: self.tracks, position: index)
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
