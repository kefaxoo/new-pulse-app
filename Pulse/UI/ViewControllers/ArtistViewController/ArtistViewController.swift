//
//  ArtistViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 27.12.23.
//

import UIKit
import PulseUIComponents
import HPParallaxHeader

protocol ArtistView: AnyObject {
    func reloadData()
}

final class ArtistViewController: BaseUIViewController {
    private lazy var artistTableHeaderView: ArtistTableHeaderView = {
        let view = ArtistTableHeaderView(artist: self.presenter.getArtist())
        return view
    }()
    
    private lazy var artistTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.delegate = self
        tableView.register(TrackTableViewCell.self)
        tableView.dataSource = self
        tableView.parallaxHeader.view = self.artistTableHeaderView
        tableView.parallaxHeader.height = UIScreen.main.bounds.width
        tableView.parallaxHeader.mode = .fill
        tableView.footerHeight = NowPlayingView.height
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0
        return tableView
    }()
    
    private let presenter: ArtistPresenterProtocol
    
    init(artist: ArtistModel) {
        self.presenter = ArtistPresenter(artist: artist)
        super.init(nibName: nil, bundle: nil)
        self.presenter.setView(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Lifecycle
extension ArtistViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
}

// MARK: -
// MARK: Lifecycle
extension ArtistViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.applyColor()
        AudioPlayer.shared.tableViewDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: -
// MARK: Setup interface methods
extension ArtistViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
    }
    
    override func setupLayout() {
        self.view.addSubview(artistTableView)
    }
    
    override func setupConstraints() {
        artistTableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
    private func setupNavigationController() {
        self.navigationItem.title = self.presenter.artistName
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ]
    }
    
    private func applyColor() {
        self.artistTableView.visibleCells.forEach { cell in
            (cell as? TrackTableViewCell)?.changeColor()
        }
    }
}

// MARK: -
// MARK: ArtistView
extension ArtistViewController: ArtistView {
    func reloadData() {
        self.artistTableView.reloadData()
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension ArtistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.countOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.countOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension ArtistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let scheme = self.presenter.scheme(inSection: section)
        
        switch scheme {
            case .popularTracks:
                return UITableView.automaticDimension
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.presenter.setupHeaderView(for: section)
    }
}

// MARK: -
// MARK: AudioPlayerTableViewDelegate
extension ArtistViewController: AudioPlayerTableViewDelegate {
    func changeStateImageView(_ state: CoverImageViewState, for track: TrackModel) {
        guard let indexPath = self.presenter.indexPath(for: track) else { return }
        
        (self.artistTableView.cellForRow(at: indexPath) as? TrackTableViewCell)?.changeState(state)
    }
}
