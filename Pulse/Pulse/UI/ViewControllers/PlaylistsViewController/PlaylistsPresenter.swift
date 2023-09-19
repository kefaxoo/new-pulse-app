//
//  PlaylistsPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import UIKit

protocol PlaylistsPresenterDelegate: AnyObject {
    func reloadData()
}

final class PlaylistsPresenter: BasePresenter {
    private var playlists       = [PlaylistModel]()
    private var showedPlaylists = [PlaylistModel]()
    
    private let type: LibraryControllerType
    
    var playlistsCount: Int {
        return playlists.count
    }
    
    private weak var delegate: PlaylistsPresenterDelegate?
    
    init(type: LibraryControllerType, delegate: PlaylistsPresenterDelegate?) {
        self.type = type
        self.delegate = delegate
        self.fetchPlaylists()
    }
    
    private func fetchPlaylists() {
        self.playlists.removeAll()
        switch type {
            case .library:
                self.playlists = RealmManager<LibraryPlaylistModel>().read().map({ PlaylistModel($0) })
            default:
                MainCoordinator.shared.popViewController()
                return
        }
        
        self.showedPlaylists = self.playlists
    }
    
    func textDidChange(_ text: String) {
        if text.isEmpty {
            self.showedPlaylists = self.playlists
        } else {
            self.showedPlaylists = self.playlists.filter({ $0.title.lowercased().contains(text) })
        }
        
        self.delegate?.reloadData()
    }
    
    private func reloadData() {
        self.fetchPlaylists()
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
        (cell as? PlaylistTableViewCell)?.setupCell(showedPlaylists[indexPath.item])
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {}
}

// MARK: -
// MARK: Lifecycle
extension PlaylistsPresenter {
    func viewWillAppear() {
        self.reloadData()
    }
}
