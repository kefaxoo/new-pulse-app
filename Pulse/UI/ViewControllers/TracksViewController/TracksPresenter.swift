//
//  TracksPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

protocol TracksPresenterDelegate: AnyObject {
    func reloadData()
    func setNavigationControllerTitle(_ title: String)
    func appendNewCells(indexPaths: [IndexPath])
}

final class TracksPresenter: BasePresenter {
    private var tracks = [TrackModel]()
    private var showedTracks = [TrackModel]()
    private var type: LibraryControllerType = .none
    private var scheme: PulseWidgetsScheme = .none
    
    private var isResultsLoading = false
    private var canLoadMore = true
    
    private var soundcloudCursor: String?
    
    private var didChangePlaylistInPlayer = false
    
    private var isFirstAppear = true
    
    private weak var delegate: TracksPresenterDelegate?
    
    var tracksCount: Int {
        return showedTracks.count
    }
    
    var tracksIsEmpty: Bool {
        return showedTracks.isEmpty
    }
    
    init(type: LibraryControllerType, scheme: PulseWidgetsScheme, delegate: TracksPresenterDelegate?) {
        self.type = type
        self.scheme = scheme
        self.delegate = delegate
        self.fetchTracks()
    }
    
    private func setTracks(_ tracks: [TrackModel]) {
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        self.tracks = tracks
        self.showedTracks = tracks
        self.delegate?.reloadData()
    }
    
    private func fetchTracks() {
        self.tracks.removeAll()
        switch type {
            case .library:
                self.tracks = RealmManager<LibraryTrackModel>().read().map({ TrackModel($0) }).sorted
            case .soundcloud:
                MainCoordinator.shared.currentViewController?.presentSpinner()
                SoundcloudProvider.shared.libraryTracks { [weak self] soundcloudTracks, cursor in
                    self?.soundcloudCursor = cursor
                    self?.setTracks(soundcloudTracks.map({ TrackModel($0) }))
                } failure: { error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    MainCoordinator.shared.popViewController()
                    AlertView.shared.presentError(
                        error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                        system: .iOS16AppleMusic
                    )
                }
            case .yandexMusic:
                MainCoordinator.shared.currentViewController?.presentSpinner()
                YandexMusicProvider.shared.libraryTracks { [weak self] yandexMusicTracks in
                    self?.setTracks(yandexMusicTracks.map({ TrackModel($0) }))
                } failure: {
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    MainCoordinator.shared.popViewController()
                    AlertView.shared.presentError(
                        error: Localization.Lines.unknownError.localization(with: Localization.Words.yandexMusic.localization),
                        system: .iOS16AppleMusic
                    )
                }
            case .none:
                switch self.scheme {
                    case .exclusiveSongs:
                        PulseProvider.shared.exclusiveTracks { [weak self] widget in
                            self?.setTracks(widget.content.map({ TrackModel($0) }))
                            self?.delegate?.setNavigationControllerTitle(widget.localizableTitle ?? widget.title)
                        } failure: { serverError, internalError in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            MainCoordinator.shared.popViewController()
                            AlertView.shared.presentError(
                                error: LocalizationManager.shared.localizeError(
                                    server: serverError,
                                    internal: internalError,
                                    default: Localization.Lines.unknownError.localization(with: "Pulse")
                                ),
                                system: .iOS16AppleMusic
                            )
                        }
                    default:
                        MainCoordinator.shared.popViewController()
                        return
                }
            case .pulse:
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
    
    func track(at indexPath: IndexPath) -> TrackModel {
        return self.tracks[indexPath.row]
    }
    
    func removeTrack(atIndex index: Int) {
        self.tracks.remove(at: index)
        self.showedTracks.remove(at: index)
    }
}

// MARK: -
// MARK: Lifecycle
extension TracksPresenter {
    func viewWillAppear() {
        if !self.isFirstAppear {
            self.reloadData()
        }
        
        self.isFirstAppear = false
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
        guard self.type != .library || self.scheme != .none else { return }
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height,
           !isResultsLoading,
           !tracks.isEmpty,
           canLoadMore {
            self.isResultsLoading = true
            MainCoordinator.shared.currentViewController?.presentSpinner()
            switch self.type {
                case .soundcloud:
                    SoundcloudProvider.shared.libraryTracks(cursor: self.soundcloudCursor) { [weak self] tracks, cursor in
                        self?.soundcloudCursor = cursor
                        self?.addNewTracks(tracks.map({ TrackModel($0) }), canLoadMore: !tracks.isEmpty)
                    } failure: { [weak self] _ in
                        self?.setCannotLoadMore()
                    }
                case .yandexMusic:
                    YandexMusicProvider.shared.libraryTracks(offset: self.tracks.count) { [weak self] tracks in
                        self?.addNewTracks(tracks.map({ TrackModel($0) }), canLoadMore: !tracks.isEmpty)
                    } failure: { [weak self] in
                        self?.setCannotLoadMore()
                    }
                case .none:
                    switch self.scheme {
                        case .exclusiveSongs:
                            PulseProvider.shared.exclusiveTracks(offset: self.tracks.count) { [weak self] widget in
                                self?.addNewTracks(widget.content.map({ TrackModel($0) }), canLoadMore: !widget.content.isEmpty)
                            } failure: { [weak self] _, _ in
                                self?.setCannotLoadMore()
                            }
                        default:
                            self.setCannotLoadMore()
                    }
                default:
                    self.setCannotLoadMore()
            }
        }
    }
    
    private func addNewTracks(_ tracks: [TrackModel], canLoadMore: Bool) {
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        let begin = self.tracks.count
        let end = begin + tracks.count
        self.tracks.append(contentsOf: tracks)
        self.showedTracks = self.tracks
        self.isResultsLoading = false
        var indexPaths = [IndexPath]()
        for i in begin..<end {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        
        self.delegate?.appendNewCells(indexPaths: indexPaths)
        self.canLoadMore = canLoadMore
    }
    
    private func setCannotLoadMore() {
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        self.isResultsLoading = false
        self.canLoadMore = false
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
