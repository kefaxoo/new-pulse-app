//
//  PlaylistPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import UIKit

final class PlaylistPresenter: BasePresenter {
    private let playlist: PlaylistModel
    
    init(_ playlist: PlaylistModel) {
        self.playlist = playlist
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension PlaylistPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: PlaylistHeaderTableViewCell.id, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        (cell as? PlaylistHeaderTableViewCell)?.setupCell(self.playlist)
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {}
}
