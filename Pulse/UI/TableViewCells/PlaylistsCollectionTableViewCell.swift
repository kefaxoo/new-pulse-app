//
//  PlaylistsCollectionTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.01.24.
//

import UIKit
import PulseUIComponents

final class PlaylistsCollectionTableViewCell: BaseUITableViewCell {
    private lazy var playlistsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 120)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.sectionInset = UIEdgeInsets(horizontal: 16)
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(PlaylistCollectionViewCell.self)
        return collectionView
    }()
    
    private var playlists = [PulsePlaylist]()

    func configure(withPlaylists playlists: [PulsePlaylist]) {
        self.playlists = playlists
        self.playlistsCollectionView.reloadData()
        self.setupConstraints()
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistsCollectionTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.separatorInset = UIEdgeInsets(right: UIScreen.main.bounds.width)
    }
    
    override func setupLayout() {
        self.contentView.addSubview(playlistsCollectionView)
    }
    
    override func setupConstraints() {
        playlistsCollectionView.snp.removeConstraints()
        
        playlistsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(playlists.map({ PlaylistCollectionViewCell.height(withPlaylist: $0) }).max() ?? 100)
        }
    }
}

// MARK: -
// MARK: UICollectionViewDataSource
extension PlaylistsCollectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.id, for: indexPath)
        (cell as? PlaylistCollectionViewCell)?.configure(withPlaylist: PlaylistModel(self.playlists[indexPath.item]))
        return cell
    }
}

// MARK: -
// MARK: UICollectionViewDelegate
extension PlaylistsCollectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        MainCoordinator.shared.pushPlaylistViewController(type: .pulse, playlist: PlaylistModel(self.playlists[indexPath.row]))
    }
}
