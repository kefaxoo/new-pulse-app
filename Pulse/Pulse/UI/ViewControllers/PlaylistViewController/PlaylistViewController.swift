//
//  PlaylistViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import UIKit
import PulseUIComponents

final class PlaylistViewController: BaseUIViewController {
    private lazy var playlistTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.dataSource = self
        tableView.register(PlaylistHeaderTableViewCell.self, TrackTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var presenter: PlaylistPresenter = {
        let presenter = PlaylistPresenter(self.playlist, type: self.type)
        presenter.delegate = self
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
// MARK: Lifecycle
extension PlaylistViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        AudioPlayer.shared.tableViewDelegate = self
        self.presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistViewController {
    override func setupLayout() {
        self.view.addSubview(playlistTableView)
    }
    
    override func setupConstraints() {
        playlistTableView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension PlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + self.presenter.tracksCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: PlaylistPresenterDelegate
extension PlaylistViewController: PlaylistPresenterDelegate {
    func reloadData() {
        self.playlistTableView.reloadData()
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension PlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter.didSelectRow(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.presenter.scrollViewDidScroll(scrollView)
    }
}

// MARK: -
// MARK: AudioPlayerTableViewDelegate
extension PlaylistViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: CoverImageViewState, position: Int) {
        let indexPath = IndexPath(row: position + 1, section: 0)
        (playlistTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}
