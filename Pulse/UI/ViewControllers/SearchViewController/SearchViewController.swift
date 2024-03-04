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
        searchController.searchBar.placeholder = Localization.Controllers.Search.SearchControllers.typeQuery.localization
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var newServiceSegmentedControl: PinterestSegmentedControl = {
        var style = PinterestSegmentStyle()
        style.indicatorColor = SettingsManager.shared.color.color
        style.titleMargin = 15
        style.titlePendingHorizontal = 14
        style.titlePendingVertical = 14
        style.titleFont = .boldSystemFont(ofSize: 14)
        style.normalTitleColor = .label.withAlphaComponent(0.5)
        style.selectedTitleColor = .white
        
        let segmentedControl = PinterestSegmentedControl(frame: .zero, segmentStyle: style, titles: [])
        
        segmentedControl.valueChange = { [weak self] index in
            self?.presenter.serviceDidChange(index: index)
            if self?.searchController.searchBar.text?.isEmpty ?? true,
               !(self?.presenter.currentService.isHistoryAvailable ?? true) {
                self?.emptySearchQuerySearchContentView.show()
            } else {
                self?.emptySearchQuerySearchContentView.hide()
            }
        }
        
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
        tableView.register(TrackTableViewCell.self, PlaylistTableViewCell.self, SearchSuggestionTableViewCell.self)
        tableView.delegate = self
        tableView.footerHeight = NowPlayingView.height
        return tableView
    }()
    
    private lazy var emptySearchQuerySearchContentView: ContentUnavailableView = {
        let contentUnavailableView = ContentUnavailableView()
        contentUnavailableView.contentImage = Constants.Images.search.image
        contentUnavailableView.titleText = Localization.Controllers.Search.ContentUnavailableViews.typeQuery.localization
        return contentUnavailableView
    }()
    
    private lazy var presenter: SearchPresenter = {
        let presenter = SearchPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    private lazy var dismissKeyboardGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
            self.newServiceSegmentedControl.selectIndex,
            self.typeSegmentedControl.selectedSegmentIndex
        )
        
        self.searchController.searchBar.tintColor = SettingsManager.shared.color.color
        AudioPlayer.shared.tableViewDelegate = self
        
        self.searchController.view.addGestureRecognizer(self.dismissKeyboardGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLibraryState), name: .updateLibraryState, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.view.removeGestureRecognizer(self.dismissKeyboardGesture)
        
        NotificationCenter.default.removeObserver(self, name: .updateLibraryState, object: nil)
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
        self.view.addSubview(newServiceSegmentedControl)
        self.view.addSubview(typeSegmentedControl)
        self.view.addSubview(resultsTableView)
        self.view.addSubview(emptySearchQuerySearchContentView)
    }
    
    override func setupConstraints() {
        newServiceSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
            make.height.equalTo(40)
        }
        
        typeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(newServiceSegmentedControl.snp.bottom).offset(10)
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
    func setupServiceSegmentedControl(items: [String], selectedIndex: Int) {
        self.newServiceSegmentedControl.titles = items
        guard !items.isEmpty else { return }
        
        self.newServiceSegmentedControl.setSelectIndex(index: selectedIndex, animated: true)
    }
    
    func setupTypeSegmentedControl(items: [String], selectedIndex: Int) {
        self.typeSegmentedControl.removeAllSegments()
        
        items.enumerated().forEach { [weak self] index, item in
            self?.typeSegmentedControl.insertSegment(withTitle: item, at: index, animated: true)
        }
        
        guard !items.isEmpty else { return }
        
        self.typeSegmentedControl.selectedSegmentIndex = selectedIndex
    }
    
    func reloadData(scrollToTop: Bool) {
        self.resultsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        self.resultsTableView.reloadData()
        guard scrollToTop else { return }
        
        self.resultsTableView.setContentOffset(.zero, animated: true)
    }
    
    override func dismissKeyboard() {
        self.searchController.searchBar.endEditing(true)
    }
    
    func appendNewCells(indexPaths: [IndexPath]) {
        self.resultsTableView.beginUpdates()
        self.resultsTableView.insertRows(at: indexPaths, with: .automatic)
        self.resultsTableView.endUpdates()
    }
    
    func setQuery(_ query: String) {
        self.searchController.searchBar.text = query
    }
}

// MARK: -
// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty,
           !self.presenter.currentService.isHistoryAvailable {
            self.emptySearchQuerySearchContentView.show()
        } else {
            self.emptySearchQuerySearchContentView.hide()
        }
        
        self.presenter.textDidChange(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.emptySearchQuerySearchContentView.show()
        self.presenter.textDidChange("")
    }
}

// MARK: -
// MARK: Actions
fileprivate extension SearchViewController {
    @objc func serviceDidChange(_ sender: UISegmentedControl) {
        self.presenter.serviceDidChange(index: sender.selectedSegmentIndex)
    }
    
    @objc func searchTypeDidChange(_ sender: UISegmentedControl) {
        self.presenter.typeDidChange(index: sender.selectedSegmentIndex)
    }
    
    @objc func dismissKeyboardAction(_ sender: UITapGestureRecognizer) {
        self.searchController.searchBar.endEditing(true)
    }
    
    @objc func updateLibraryState(_ notification: Notification) {
        guard self.presenter.currentType == .tracks,
              let track = notification.userInfo?["track"] as? TrackModel,
              let state = notification.userInfo?["state"] as? TrackLibraryState,
              let index = self.presenter.trackIndex(for: track)
        else { return }
        
        (self.resultsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TrackTableViewCell)?.updateTrackState(state)
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard self.presenter.currentType == .tracks,
              let track = self.presenter.track(at: indexPath)
        else { return nil }
        
        return ActionsManager(nil)
            .trackSwipeActionsConfiguration(
                for: track,
                swipeDirection: .leadingToTrailing
            )
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard self.presenter.currentType == .tracks,
              let track = self.presenter.track(at: indexPath)
        else { return nil }
        
        return ActionsManager(nil).trackSwipeActionsConfiguration(for: track, swipeDirection: .trailingToLeading)
    }
}

// MARK: -
// MARK: AudioPlayerTableViewDelegate
extension SearchViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: CoverImageViewState, for track: TrackModel) {
        guard let index = self.presenter.trackIndex(for: track) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        (self.resultsTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}
