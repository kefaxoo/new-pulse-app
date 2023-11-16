//
//  SearchViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit
import PulseUIComponents

final class SearchViewController: BaseUIViewController {
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Type track, artist, album..."
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var serviceSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(self, action: #selector(serviceDidChange), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var typeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(self, action: #selector(searchTypeDidChange), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var resultsTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.dataSource = self
        tableView.register(TrackTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var emptySearchQuerySearchContentView: ContentUnavailableView = {
        let contentUnavailableView = ContentUnavailableView()
        contentUnavailableView.contentImage = Constants.Images.search.image
        contentUnavailableView.titleText = "Type search in text field"
        return contentUnavailableView
    }()
    
    private lazy var presenter: SearchPresenter = {
        let presenter = SearchPresenter()
        presenter.delegate = self
        return presenter
    }()
}

// MARK: -
// MARK: Lifecycle methods
extension SearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear(
            self.serviceSegmentedControl.selectedSegmentIndex,
            self.typeSegmentedControl.selectedSegmentIndex
        )
        
        self.searchController.searchBar.tintColor = SettingsManager.shared.color.color
        self.presenter.search()
        AudioPlayer.shared.tableViewDelegate = self
    }
}

// MARK: -
// MARK: Setup interface methods
extension SearchViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
    }
    
    override func setupLayout() {
        self.view.addSubview(serviceSegmentedControl)
        self.view.addSubview(typeSegmentedControl)
        self.view.addSubview(resultsTableView)
        self.view.addSubview(emptySearchQuerySearchContentView)
    }
    
    override func setupConstraints() {
        serviceSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
        }
        
        typeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(serviceSegmentedControl.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
        }
        
        resultsTableView.snp.makeConstraints { make in
            make.top.equalTo(typeSegmentedControl.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        emptySearchQuerySearchContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNavigationController() {
        self.navigationItem.searchController = searchController
    }
}

// MARK: -
// MARK: SearchPresenterDelegate
extension SearchViewController: SearchPresenterDelegate {
    func setupServiceSegmentedControl(items: [String]) {
        self.serviceSegmentedControl.removeAllSegments()
        
        items.enumerated().forEach { [weak self] index, item in
            self?.serviceSegmentedControl.insertSegment(withTitle: item, at: index, animated: true)
        }
        
        guard !items.isEmpty else { return }
        
        self.serviceSegmentedControl.selectedSegmentIndex = 0
    }
    
    func setupTypeSegmentedControl(items: [String]) {
        self.typeSegmentedControl.removeAllSegments()
        
        items.enumerated().forEach { [weak self] index, item in
            self?.typeSegmentedControl.insertSegment(withTitle: item, at: index, animated: true)
        }
        
        guard !items.isEmpty else { return }
        
        self.typeSegmentedControl.selectedSegmentIndex = 0
    }
    
    func reloadData(scrollToTop: Bool) {
        self.resultsTableView.reloadData()
        guard scrollToTop else { return }
        
        self.resultsTableView.setContentOffset(.zero, animated: true)
    }
}

// MARK: -
// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.emptySearchQuerySearchContentView.show()
        } else {
            self.emptySearchQuerySearchContentView.hide()
        }
        
        self.presenter.textDidChange(searchText)
    }
}

// MARK: -
// MARK: Actions
extension SearchViewController {
    @objc private func serviceDidChange(_ sender: UISegmentedControl) {
        self.presenter.serviceDidChange(index: sender.selectedSegmentIndex)
    }
    
    @objc private func searchTypeDidChange(_ sender: UISegmentedControl) {
        self.presenter.typeDidChange(index: sender.selectedSegmentIndex)
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.resultsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
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
extension SearchViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: CoverImageViewState, position: Int) {
        guard self.presenter.currentType == .tracks else { return }
        
        let indexPath = IndexPath(row: position, section: 0)
        (self.resultsTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}
