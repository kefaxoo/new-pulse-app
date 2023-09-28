//
//  TracksViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

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
    
    private lazy var emptyView: InformationView = {
        let view = InformationView(style: .empty(title: "There is no tracks"))
        view.isHidden = true
        return view
    }()
    
    private lazy var presenter: TracksPresenter = {
        let presenter = TracksPresenter(type: self.type, delegate: self)
        emptyView.isHidden = presenter.tracksCount > 0
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
}

// MARK: -
// MARK: TracksPresenterDelegate
extension TracksViewController: TracksPresenterDelegate {
    func reloadData() {
        self.emptyView.isHidden = self.presenter.tracksCount > 0
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
