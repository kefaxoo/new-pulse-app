//
//  PlaylistViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import UIKit

final class PlaylistViewController: BaseUIViewController {
    private lazy var playlistTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        return tableView
    }()
    
    private lazy var presenter: PlaylistPresenter = {
        let presenter = PlaylistPresenter()
        return presenter
    }()
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistViewController {
    override func setupLayout() {
        self.view.addSubview(playlistTableView)
    }
    
    override func setupConstraints() {
        playlistTableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}
