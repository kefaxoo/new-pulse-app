//
//  TracksViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit
import PulseUIComponents

final class TracksViewController: BaseUIViewController {
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = Localization.Controllers.Tracks.SearchControllers.typeQuery.localization
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var tracksTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.dataSource = self
        tableView.register(TrackTableViewCell.self)
        tableView.delegate = self
        tableView.footerHeight = NowPlayingView.height
        return tableView
    }()
    
    private lazy var emptyView: ContentUnavailableView = {
        let view = ContentUnavailableView()
        view.titleText = Localization.Controllers.Tracks.ContentUnavailableViews.noContent.localization
        view.isHidden = true
        return view
    }()
    
    private lazy var presenter: TracksPresenter = {
        let presenter = TracksPresenter(type: self.type, scheme: self.scheme, delegate: self)
        return presenter
    }()
    
    private let type: LibraryControllerType
    private let scheme: PulseWidgetsScheme
    
    init(type: LibraryControllerType, scheme: PulseWidgetsScheme) {
        self.type = type
        self.scheme = scheme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension TracksViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
    }
    
    override func setupLayout() {
        self.view.addSubview(tracksTableView)
        self.view.addSubview(emptyView)
    }
    
    override func setupConstraints() {
        tracksTableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints({ $0.leading.trailing.centerY.equalToSuperview() })
    }
    
    private func setupNavigationController() {
        self.navigationItem.title = Localization.Words.tracks.localization
        guard self.type == .library else { return }
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func applyColor() {
        self.tracksTableView.visibleCells.forEach({ ($0 as? TrackTableViewCell)?.changeColor() })
    }
}

// MARK: -
// MARK: Lifecycle
extension TracksViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applyColor()
        AudioPlayer.shared.tableViewDelegate = self
        self.addNotification(name: .trackLibraryStateWasUpdated, selector: #selector(updateLibraryState))
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension TracksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.tracksCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension TracksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter.didSelectRow(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.presenter.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return ActionsManager(nil)
            .trackSwipeActionsConfiguration(
                for: self.presenter.track(at: indexPath),
                swipeDirection: .leadingToTrailing
            )
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return ActionsManager(nil).trackSwipeActionsConfiguration(
                for: self.presenter.track(at: indexPath),
                swipeDirection: .trailingToLeading
            )
    }
}

// MARK: -
// MARK: TracksPresenterDelegate
extension TracksViewController: TracksPresenterDelegate {
    func reloadData() {
        if !self.presenter.tracksIsEmpty {
            self.emptyView.hide()
        } else {
            self.emptyView.show()
        }
        
        self.tracksTableView.reloadData()
    }
    
    func setNavigationControllerTitle(_ title: String) {
        self.navigationItem.title = title
    }
    
    func appendNewCells(indexPaths: [IndexPath]) {
        self.tracksTableView.beginUpdates()
        self.tracksTableView.insertRows(at: indexPaths, with: .automatic)
        self.tracksTableView.endUpdates()
    }
}

// MARK: -
// MARK: UISearchBarDelegate
extension TracksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.textDidChange(searchText)
    }
}

// MARK: -
// MARK: AudioPlayerTableViewDelegate
extension TracksViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: CoverImageViewState, for track: TrackModel) {
        guard let index = self.presenter.index(for: track) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        (self.tracksTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}

// MARK: -
// MARK: Actions
extension TracksViewController {
    @objc func updateLibraryState(_ notification: Notification) {
        let (track, state) = NewLibraryManager.parseNotification(notification)
        
        guard let track,
              let index = self.presenter.index(for: track),
              let state
        else { return }
        
        if self.type == .library,
           state == .none {
            self.presenter.removeTrack(atIndex: index)
            self.tracksTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            AudioPlayer.shared.removeTrack(track)
        } else {
            let cell = self.tracksTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TrackTableViewCell
            
            cell?.updateButtonMenu()
            cell?.updateTrackState(state)
        }
    }
}
