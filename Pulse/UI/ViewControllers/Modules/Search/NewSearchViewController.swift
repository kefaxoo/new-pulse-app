//
//  NewSearchViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.03.24.
//

import UIKit
import PulseUIComponents

final class NewSearchViewController: BaseUIViewController {
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = Localization.Controllers.Search.SearchControllers.typeQuery.localization
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var emptySearchQueryContentView: ContentUnavailableView = {
        let view = ContentUnavailableView()
        view.contentImage = Constants.Images.search.image
        view.titleText = Localization.Controllers.Search.ContentUnavailableViews.typeQuery.localization
        return view
    }()
    
    private lazy var serviceSegmentedControl: PinterestSegmentedControl = {
        var style = PinterestSegmentStyle()
        style.indicatorColor = SettingsManager.shared.color.color
        style.titleMargin = 15
        style.titlePendingHorizontal = 14
        style.titlePendingVertical = 14
        style.titleFont = .boldSystemFont(ofSize: 14)
        style.normalTitleColor = .label.withAlphaComponent(0.5)
        style.selectedTitleColor = .white
        
        let segmentedControl = PinterestSegmentedControl(frame: .zero, segmentStyle: style, richTextTitles: [])
        
        segmentedControl.isHidden = true
        segmentedControl.valueChange = { [weak self] index in
            self?.viewModel.isSearchSuggestions = false
            self?.viewModel.serviceDidChange(index: index)
            if self?.searchController.searchBar.text?.isEmpty ?? true {
                self?.emptySearchQueryContentView.show()
            } else {
                self?.emptySearchQueryContentView.hide()
            }
        }
        
        return segmentedControl
    }()
    
    private lazy var typeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(self, action: #selector(searchTypeDidChange), for: .valueChanged)
        segmentedControl.isHidden = true
        return segmentedControl
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(serviceSegmentedControl)
        stackView.addArrangedSubview(typeSegmentedControl)
        return stackView
    }()
    
    private lazy var resultsTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.dataSource = self
        tableView.register(
            TrackTableViewCell.self,
            PlaylistTableViewCell.self,
            SearchSuggestionTableViewCell.self
        )
        
        tableView.delegate = self
        tableView.footerHeight = NowPlayingView.height
        return tableView
    }()
    
    private lazy var dismissKeyboardGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
    }()
    
    private var isViewWillAppear = false
    
    private let viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Lifecycle
extension NewSearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
        self.viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isViewWillAppear = true
        self.addNotification(name: .trackLibraryStateWasUpdated, selector: #selector(updateLibraryState), object: nil)
        self.searchController.view.addGestureRecognizer(self.dismissKeyboardGesture)
        self.searchController.searchBar.tintColor = SettingsManager.shared.color.color
        AudioPlayer.shared.tableViewDelegate = self
        self.viewModel.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.view.removeGestureRecognizer(self.dismissKeyboardGesture)
    }
}

// MARK: -
// MARK: Setup interface methods
extension NewSearchViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
    }
    
    override func setupLayout() {
        self.view.addSubview(topStackView)
        self.view.addSubview(resultsTableView)
        self.view.addSubview(emptySearchQueryContentView)
    }
    
    override func setupConstraints() {
        emptySearchQueryContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        topStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(horizontal: 20)
        }
        
        serviceSegmentedControl.snp.makeConstraints({ $0.height.equalTo(40) })
        
        resultsTableView.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigationController() {
        self.navigationItem.searchController = searchController
    }
}

// MARK: -
// MARK: Bindings
private extension NewSearchViewController {
    func setupBindings() {
        self.viewModel.setupCurrentServicesBinding { [weak self] services in
            let serviceTitles = services.map({ $0.title })
            self?.serviceSegmentedControl.titles = serviceTitles
            guard !services.isEmpty,
                  let selectedIndex = self?.viewModel.currentServiceIndex
            else { return }
            
            self?.serviceSegmentedControl.setSelectIndex(index: selectedIndex, animated: false)
        }
        
        self.viewModel.setupCurrentTypesBinding { [weak self] searchTypes in
            self?.typeSegmentedControl.removeAllSegments()
            searchTypes.enumerated().forEach({ self?.typeSegmentedControl.insertSegment(withTitle: $0.element.title, at: $0.offset, animated: true) })
            guard !searchTypes.isEmpty,
                  let selectedIndex = self?.viewModel.currentTypeIndex
            else { return }
            
            self?.typeSegmentedControl.selectedSegmentIndex = selectedIndex
        }
        
        self.viewModel.setupSearchResponseBinding { [weak self] _ in
            if !(self?.viewModel.isResultsLoading ?? true) {
                self?.resultsTableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
            
            if self?.viewModel.shouldScrollToTop ?? false {
                self?.resultsTableView.setContentOffset(.zero, animated: true)
                self?.viewModel.shouldScrollToTop = false
            }
        }
        
        self.viewModel.setupViewQueryBinding { [weak self] query in
            self?.searchController.searchBar.text = query
        }
        
        self.viewModel.setupShouldShowContentUnavailableView { [weak self] isShow in
            if isShow {
                self?.emptySearchQueryContentView.show()
            } else {
                self?.emptySearchQueryContentView.hide()
            }
        }
        
        self.viewModel.setupIndexPaths { [weak self] newIndexPaths in
            self?.resultsTableView.beginUpdates()
            self?.resultsTableView.insertRows(at: newIndexPaths, with: .bottom)
            self?.resultsTableView.endUpdates()
        }
    }
}

// MARK: -
// MARK: Actions
private extension NewSearchViewController {
    @objc func searchTypeDidChange(_ sender: UISegmentedControl) {
        self.viewModel.searchTypeDidChange(index: sender.selectedSegmentIndex)
    }
    
    @objc func dismissKeyboardAction(_ sender: UITapGestureRecognizer) {
        self.searchController.searchBar.endEditing(true)
    }
    
    @objc func updateLibraryState(_ notification: Notification) {
        let (track, state) = NewLibraryManager.parseNotification(notification)
        
        guard self.viewModel.currentType == .tracks,
              let track,
              let index = self.viewModel.trackIndex(for: track),
              let state
        else { return }
        
        let cell = self.resultsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TrackTableViewCell
        
        cell?.updateButtonMenu()
        cell?.updateTrackState(state)
    }
}

// MARK: -
// MARK: UISearchBarDelegate
extension NewSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.emptySearchQueryContentView.show()
        } else {
            self.emptySearchQueryContentView.hide()
        }
        
        self.viewModel.isSearchSuggestions = true
        self.viewModel.searchFor(query: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.serviceSegmentedControl.smoothIsHidden = false
        self.typeSegmentedControl.smoothIsHidden = false
        if !self.isViewWillAppear {
            self.viewModel.isSearchSuggestions = true
        }
        
        self.isViewWillAppear = false
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.serviceSegmentedControl.isHidden = true
        self.typeSegmentedControl.isHidden = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.isSearchSuggestions = false
        self.viewModel.searchFor(query: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.isSearchSuggestions = true
        if let query = searchBar.text {
            self.viewModel.searchFor(query: query)
        }
        
        self.dismissKeyboard()
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension NewSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.resultsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension NewSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchController.searchBar.endEditing(true)
        self.viewModel.didSelectRow(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewModel.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - Swipe actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.viewModel.currentType == .tracks,
           let track = self.viewModel.track(at: indexPath) {
            return ActionsManager(nil).trackSwipeActionsConfiguration(for: track, swipeDirection: .leadingToTrailing)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.viewModel.currentType == .tracks,
           let track = self.viewModel.track(at: indexPath) {
            return ActionsManager(nil).trackSwipeActionsConfiguration(for: track, swipeDirection: .trailingToLeading)
        }
        
        return nil
    }
}

// MARK: -
// MARK: AudioPlayerTableViewDelegate
extension NewSearchViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: CoverImageViewState, for track: TrackModel) {
        guard let index = self.viewModel.trackIndex(for: track) else { return }
        
        let cell = self.resultsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TrackTableViewCell
        
        cell?.changeState(state)
        cell?.updateButtonMenu()
    }
}
