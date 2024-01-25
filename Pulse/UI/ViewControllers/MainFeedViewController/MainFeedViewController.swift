//
//  MainFeedViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import UIKit
import PulseUIComponents

protocol MainFeedView: AnyObject {
    func reloadData()
    func reloadSection(_ section: Int)
}

final class MainFeedViewController: BaseUIViewController {
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = SettingsManager.shared.color.color
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var mainFeedTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.footerHeight = NowPlayingView.height
        tableView.register(StoriesTableViewCell.self, TrackTableViewCell.self, PlaylistsCollectionTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()
    
    private let presenter: MainFeedProtocol
    
    init() {
        self.presenter = MainFeedPresenter()
        super.init(nibName: nil, bundle: nil)
        self.presenter.setView(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Lifecycle
extension MainFeedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applyColor()
        AudioPlayer.shared.tableViewDelegate = self
    }
}

// MARK: -
// MARK: Setup interface methods
extension MainFeedViewController {
    override func setupLayout() {
        self.view.addSubview(mainFeedTableView)
    }
    
    override func setupConstraints() {
        mainFeedTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaInsets)
            make.bottom.equalToSuperview()
        }
    }
    
    func applyColor() {
        self.mainFeedTableView.visibleCells.forEach({ ($0 as? TrackTableViewCell)?.changeColor() })
    }
}

// MARK: -
// MARK: Actions
private extension MainFeedViewController {
    @objc func fetchData() {
        self.presenter.fetchData()
    }
    
    func headerDidTap(_ scheme: PulseWidgetsScheme) {
        switch scheme {
            case .exclusiveSongs:
                MainCoordinator.shared.pushTracksViewController(scheme: scheme)
            default:
                break
        }
    }
}

// MARK: -
// MARK: MainFeedView
extension MainFeedViewController: MainFeedView {
    func reloadData() {
        self.refreshControl.endRefreshing()
        self.mainFeedTableView.reloadData()
    }
    
    func reloadSection(_ section: Int) {
        self.mainFeedTableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension MainFeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.countOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.countOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension MainFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let scheme = self.presenter.scheme(for: section) else { return 0 }
        
        switch scheme {
            case .exclusiveSongs, .playlists:
                return UITableView.automaticDimension
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let scheme = self.presenter.scheme(for: section),
              let widget = self.presenter.widget(for: scheme)
        else { return nil }
        
        switch scheme {
            case .exclusiveSongs:
                guard let exclusiveTracks = widget as? PulseWidget<PulseExclusiveTrack> else { return nil }
                
                return ButtonTableHeaderView().configure(
                    withWidget: exclusiveTracks,
                    shouldShowButton: exclusiveTracks.content.count >= 5
                ) { [scheme, weak self] in
                    self?.headerDidTap(scheme)
                }
            case .playlists:
                guard let playlists = widget as? PulseWidget<PulsePlaylist> else { return nil }
                
                return ButtonTableHeaderView().configure(
                    withWidget: playlists,
                    shouldShowButton: playlists.content.count > 1
                ) { [scheme, weak self] in
                    self?.headerDidTap(scheme)
                }
            default:
                return nil
        }
    }
}

// MARK: -
// MARK: AudioPlayerTableViewDelegate
extension MainFeedViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: PulseUIComponents.CoverImageViewState, for track: TrackModel) {
        guard let indexPath = self.presenter.indexPath(for: track) else { return }
        
        (self.mainFeedTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}
