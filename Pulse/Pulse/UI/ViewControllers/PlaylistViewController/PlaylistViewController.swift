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
        tableView.dataSource = self
        tableView.register(PlaylistHeaderTableViewCell.self)
        return tableView
    }()
    
    private lazy var presenter: PlaylistPresenter = {
        let presenter = PlaylistPresenter(self.playlist)
        return presenter
    }()
    
    private let type: LibraryControllerType
    private let playlist: PlaylistModel
    
    init(type: LibraryControllerType, playlist: PlaylistModel) {
        self.type = type
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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

// MARK: -
// MARK: UITableViewDataSource
extension PlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}
