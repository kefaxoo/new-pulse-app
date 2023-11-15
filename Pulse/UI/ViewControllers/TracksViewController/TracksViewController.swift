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
        searchController.searchBar.placeholder = "Type track..."
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var tracksTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.dataSource = self
        tableView.register(TrackTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var emptyView: ContentUnavailableView = {
        let view = ContentUnavailableView()
        view.titleText = "There is no content"
        view.isHidden = true
        return view
    }()
    
    private lazy var presenter: TracksPresenter = {
        let presenter = TracksPresenter(type: self.type, delegate: self)
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
        self.navigationItem.title = "Tracks"
        guard self.type == .library else { return }
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: -
// MARK: Lifecycle
extension TracksViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        AudioPlayer.shared.tableViewDelegate = self
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
}

// MARK: -
// MARK: TracksPresenterDelegate
extension TracksViewController: TracksPresenterDelegate {
    func reloadData() {
        if self.presenter.tracksIsEmpty {
            self.emptyView.hide()
        } else {
            self.emptyView.show()
        }
        
        self.tracksTableView.reloadData()
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
    func changeStateImageView(_ state: PulseUIComponents.CoverImageViewState, position: Int) {
        let indexPath = IndexPath(row: position, section: 0)
        (tracksTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}
