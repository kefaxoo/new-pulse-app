//
//  PlaylistsPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import UIKit

protocol PlaylistsPresenterDelegate: AnyObject {
    var typePlaylistsSelectedIndex: Int { get }
    
    func reloadData()
}

fileprivate struct PlaylistsModel {
    var playlists       = [PlaylistModel]()
    var showedPlaylists = [PlaylistModel]()
    let type            : LibraryPlaylistType
    
    init(type: LibraryPlaylistType, playlists: [PlaylistModel] = []) {
        self.type = type
        self.playlists = playlists
        self.showedPlaylists = playlists
    }
    
    mutating func resetShowedPlaylists() {
        self.showedPlaylists = self.playlists
    }
    
    mutating func filterShowedPlaylists(_ isIncluded: (PlaylistModel) throws -> Bool) {
        guard let filteredPlaylists = try? self.playlists.filter(isIncluded) else { return }
        
        self.showedPlaylists = filteredPlaylists
    }
    
    func at(_ index: Int) -> PlaylistModel {
        return self.showedPlaylists[index]
    }
    
    func replaceCover(_ cover: ImageModel, at index: Int) {
        self.showedPlaylists[index].image = cover
        self.playlists.first(where: { $0.id == self.showedPlaylists[index].id })?.image = cover
    }
}

final class PlaylistsPresenter: BasePresenter {
    private var playlists       = [PlaylistsModel]()
    private let type            : LibraryControllerType
    
    private var soundcloudCursor: String?
    
    var playlistsCount: Int {
        guard !playlists.isEmpty,
              let typeIndex = self.delegate?.typePlaylistsSelectedIndex,
              playlists.count > typeIndex
        else { return 0 }
        
        return self.playlists[typeIndex].showedPlaylists.count
    }
    
    var isSegmentedControlHidden: Bool {
        return self.type == .library || self.type == .none
    }
    
    var segmentsForControl: [LibraryPlaylistType] {
        return self.type.service.playlistsSegments
    }
    
    private weak var delegate: PlaylistsPresenterDelegate?
    
    init(type: LibraryControllerType, delegate: PlaylistsPresenterDelegate?) {
        self.type = type
        self.delegate = delegate
        self.fetchPlaylists()
    }
    
    private func fetchPlaylists() {
        switch type {
            case .library:
                self.playlists.append(PlaylistsModel(type: .user, playlists: RealmManager<LibraryPlaylistModel>().read().map({ PlaylistModel($0) })))
            case .soundcloud:
                let type = self.segmentsForControl[self.delegate?.typePlaylistsSelectedIndex ?? 0]
                guard !self.playlists.contains(where: { $0.type == type }) else { return }
                
                MainCoordinator.shared.currentViewController?.presentSpinner()
                switch type {
                    case .user:
                        SoundcloudProvider.shared.libraryPlaylists { [weak self] soundcloudPlaylists, cursor in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            if !(self?.playlists.contains(where: { $0.type == type }) ?? false) {
                                self?.playlists.append(PlaylistsModel(type: .user, playlists: soundcloudPlaylists.map({ PlaylistModel($0) })))
                            }
                            
                            self?.soundcloudCursor = cursor
                            self?.delegate?.reloadData()
                        } failure: { error in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            MainCoordinator.shared.popViewController()
                            AlertView.shared.presentError(
                                error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"), 
                                system: .iOS16AppleMusic
                            )
                        }
                    case .liked:
                        SoundcloudProvider.shared.likedPlaylists { [weak self] soundcloudPlaylists, cursor in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            if !(self?.playlists.contains(where: { $0.type == type }) ?? false) {
                                self?.playlists.append(PlaylistsModel(type: .liked, playlists: soundcloudPlaylists.map({ PlaylistModel($0) })))
                            }
                            
                            self?.soundcloudCursor = cursor
                            self?.delegate?.reloadData()
                        } failure: { error in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            MainCoordinator.shared.popViewController()
                            AlertView.shared.presentError(
                                error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                                system: .iOS16AppleMusic
                            )
                        }
                }
            default:
                MainCoordinator.shared.popViewController()
                return
        }
    }
    
    func textDidChange(_ text: String) {
        guard let index = self.delegate?.typePlaylistsSelectedIndex else { return }
        
        if text.isEmpty {
            self.playlists[index].resetShowedPlaylists()
        } else {
            self.playlists[index].filterShowedPlaylists({ $0.title.lowercased().contains(text) })
        }
        
        self.delegate?.reloadData()
    }
    
    private func reloadData() {
        self.fetchPlaylists()
        self.delegate?.reloadData()
    }
    
    func playlistsTypeDidChange() {
        guard let typeIndex = self.delegate?.typePlaylistsSelectedIndex else { return }
        
        if typeIndex + 1 > self.playlists.count {
            self.fetchPlaylists()
            return
        }
        
        self.delegate?.reloadData()
    }
}

// MARK: -
// MARK: Table view methods
extension PlaylistsPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        self.setupCell(tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.id, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        guard let typeIndex = self.delegate?.typePlaylistsSelectedIndex else { return cell }
        
        (cell as? PlaylistTableViewCell)?.setupCell(self.playlists[typeIndex].at(indexPath.item), updateCoverIfNeeded: { [weak self] cover in
            self?.playlists[typeIndex].replaceCover(ImageModel(cover), at: indexPath.item)
        })
        
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let typeIndex = self.delegate?.typePlaylistsSelectedIndex else { return }
        
        MainCoordinator.shared.pushPlaylistViewController(type: self.type, playlist: self.playlists[typeIndex].at(indexPath.item))
    }
}

// MARK: -
// MARK: Lifecycle
extension PlaylistsPresenter {
    func viewWillAppear() {
        self.reloadData()
    }
}
