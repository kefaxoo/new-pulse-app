//
//  PlaylistsViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import UIKit

final class PlaylistsViewController: BaseUIViewController {
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Type playlist name..."
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var playlistsTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.isHidden = true
        segmentedControl.addTarget(self, action: #selector(playlistsTypeDidChange), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var playlistsTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.dataSource = self
        tableView.register(PlaylistTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var emptyView: InformationView = {
        let view = InformationView(style: .empty(title: "There is no playlists"))
        view.isHidden = true
        return view
    }()
    
    private lazy var presenter: PlaylistsPresenter = {
        let presenter = PlaylistsPresenter(type: self.type, delegate: self)
        return presenter
    }()
    
    private let type: LibraryControllerType
    
    init(type: LibraryControllerType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistsViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
        self.setupSegmentedControl()
    }
    
    override func setupLayout() {
        self.view.addSubview(playlistsTableView)
        playlistsTableView.tableHeaderView = self.playlistsTypeSegmentedControl
        
        self.view.addSubview(emptyView)
    }
    
    override func setupConstraints() {
        playlistsTypeSegmentedControl.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(self.playlistsTypeSegmentedControl.defaultHeight)
        }
        
        playlistsTableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        
        emptyView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(60)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(60)
        }
    }
    
    private func setupNavigationController() {
        self.navigationItem.title = "Playlists"
        guard self.type == .library else { return }
        
        self.navigationItem.searchController = self.searchController
    }
    
    private func setupSegmentedControl() {
        self.playlistsTypeSegmentedControl.removeAllSegments()
        self.presenter.segmentsForControl.enumerated().forEach { [weak self] index, segmentType in
            self?.playlistsTypeSegmentedControl.insertSegment(withTitle: segmentType.title, at: index, animated: true)
        }
        
        guard !self.presenter.segmentsForControl.isEmpty else { return }
        
        self.playlistsTypeSegmentedControl.selectedSegmentIndex = 0
    }
}

// MARK: -
// MARK: Lifecycle
extension PlaylistsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playlistsTypeSegmentedControl.isHidden = self.presenter.isSegmentedControlHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
    }
}

// MARK: -
// MARK: Actions
fileprivate extension PlaylistsViewController {
    @objc func playlistsTypeDidChange(_ sender: UISegmentedControl) {
        self.presenter.playlistsTypeDidChange()
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension PlaylistsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.playlistsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension PlaylistsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter.didSelectRow(at: indexPath)
    }
}

// MARK: -
// MARK: TracksPresenterDelegate
extension PlaylistsViewController: PlaylistsPresenterDelegate {
    func reloadData() {
        self.emptyView.isHidden = self.presenter.playlistsCount > 0
        self.playlistsTableView.reloadData()
    }
    
    var typePlaylistsSelectedIndex: Int {
        guard self.playlistsTypeSegmentedControl.selectedSegmentIndex >= 0 else { return 0 }
        
        return self.playlistsTypeSegmentedControl.selectedSegmentIndex
    }
}

// MARK: -
// MARK: UISearchBarDelegate
extension PlaylistsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.textDidChange(searchText)
    }
}
