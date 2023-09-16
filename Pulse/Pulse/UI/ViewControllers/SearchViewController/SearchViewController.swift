//
//  SearchViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

final class SearchViewController: BaseUIViewController {
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Type track, artist, album..."
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
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
}

// MARK: -
// MARK: Setup interface methods
extension SearchViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
    }
    
    override func setupLayout() {
        self.view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(serviceSegmentedControl)
        mainStackView.addArrangedSubview(typeSegmentedControl)
        mainStackView.addArrangedSubview(resultsTableView)
    }
    
    override func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalToSuperview()
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
        items.enumerated().forEach { [weak self] index, item in
            self?.serviceSegmentedControl.insertSegment(withTitle: item, at: index, animated: true)
        }
        
        guard !items.isEmpty else { return }
        
        self.serviceSegmentedControl.selectedSegmentIndex = 0
    }
    
    func setupTypeSegmentedControl(items: [String]) {
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
        return self.presenter.setupCell(tableView: tableView, for: indexPath)
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
