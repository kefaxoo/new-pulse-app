//
//  SearchPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

protocol SearchPresenterDelegate: AnyObject {
    func setupServiceSegmentedControl(items: [String])
    func setupTypeSegmentedControl(items: [String])
    func reloadData(scrollToTop: Bool)
}

extension SearchPresenterDelegate {
    func reloadData(scrollToTop: Bool = true) {
        self.reloadData(scrollToTop: scrollToTop)
    }
}

final class SearchPresenter: BasePresenter {
    private let services = ServiceType.searchController
    private var query = ""
    private var timer: Timer?
    
    private var currentService: ServiceType = .none
    private var currentSource: SourceType {
        return self.currentService.source
    }
    
    private(set) var currentType: SearchType = .none
    private var searchResponse: SearchResponse?
    
    private var isResultsLoading = false
    private var didChangePlaylistInPlayer = false
    
    weak var delegate: SearchPresenterDelegate?
    
    var resultsCount: Int {
        return searchResponse?.results.count ?? 0
    }
    
    func viewDidLoad() {
        self.delegate?.setupServiceSegmentedControl(items: services.map({ $0.title }))
        guard !services.isEmpty else { return }
        
        self.currentService = services[0]
        let searchTypes = SearchType.types(for: services[0])
        self.delegate?.setupTypeSegmentedControl(items: searchTypes.map({ $0.title }))
        
        guard !searchTypes.isEmpty else { return }
        
        self.currentType = searchTypes[0]
    }
    
    func textDidChange(_ text: String) {
        timer?.invalidate()
        
        if text.isEmpty {
            self.searchResponse = nil
            self.delegate?.reloadData()
            MuffonProvider.shared.cancelTask()
            return
        }
        
        self.query = text
        timer = Timer(timeInterval: 1, target: self, selector: #selector(search), userInfo: nil, repeats: false)
        timer?.fire()
    }
    
    func serviceDidChange(index: Int) {
        self.currentService = services[index]
        self.textDidChange(self.query)
    }
    
    func typeDidChange(index: Int) {
        self.currentType = SearchType.types(for: self.currentService)[index]
        self.textDidChange(self.query)
    }
    
    @objc func search() {
        timer?.invalidate()
        
        guard !self.query.isEmpty else {
            MuffonProvider.shared.cancelTask()
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            return
        }
        
        self.didChangePlaylistInPlayer = false
        MainCoordinator.shared.currentViewController?.presentSpinner()
        switch self.currentService.source {
            case .muffon:
                MuffonProvider.shared.search(query: query, in: self.currentService, type: self.currentType) { [weak self] response in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self?.searchResponse = response
                    self?.delegate?.reloadData()
                } failure: {
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(error: "Unknown Muffon Error", system: .iOS16AppleMusic)
                }
            case .soundcloud:
                SoundcloudProvider.shared.search(query: query, searchType: self.currentType) { [weak self] response in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self?.searchResponse = response
                    self?.delegate?.reloadData()
                } failure: { error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(error: error?.message ?? "Unknown Soundcloud Error", system: .iOS16AppleMusic)
                }

            case .none:
                MainCoordinator.shared.currentViewController?.dismissSpinner()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height,
           !isResultsLoading,
           resultsCount > 0,
           let searchResponse,
           searchResponse.canLoadMore {
            self.isResultsLoading = true
            MainCoordinator.shared.currentViewController?.presentSpinner()
            switch currentSource {
                case .muffon:
                    MuffonProvider.shared.search(
                        query: self.query,
                        in: self.currentService,
                        type: self.currentType, 
                        page: searchResponse.page + 1
                    ) { [weak self] searchResponse in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self?.searchResponse?.addResults(searchResponse)
                        self?.delegate?.reloadData(scrollToTop: false)
                        self?.isResultsLoading = false
                    } failure: { [weak self] in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self?.searchResponse?.cannotLoadMore()
                        self?.isResultsLoading = false
                    }
                case .soundcloud:
                    SoundcloudProvider.shared.search(
                        query: self.query,
                        searchType: self.currentType,
                        offset: self.resultsCount
                    ) { searchResponse in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self.searchResponse?.addResults(searchResponse)
                        self.delegate?.reloadData(scrollToTop: false)
                        self.isResultsLoading = false
                    } failure: { [weak self] _ in
                        self?.searchResponse?.cannotLoadMore()
                        self?.isResultsLoading = false
                    }
                default:
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self.isResultsLoading = false
                    self.searchResponse?.cannotLoadMore()
            }
        }
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension SearchPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: self.currentType.id, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        guard self.currentType != .none else { return UITableViewCell() }
        
        switch self.currentType {
            case .tracks:
                let track: TrackModel
                switch self.currentSource {
                    case .muffon:
                        guard let muffonTrack = self.searchResponse?.results[indexPath.item] as? MuffonTrack else { return UITableViewCell() }
                        
                        track = TrackModel(muffonTrack)
                    case .soundcloud:
                        guard let soundcloudTrack = self.searchResponse?.results[indexPath.item] as? SoundcloudTrack else { return UITableViewCell() }
                        
                        track = TrackModel(soundcloudTrack)
                    default:
                        return UITableViewCell()
                }
                
                (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track), isSearchController: true)
                return cell
            default:
                return UITableViewCell()
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch self.currentType {
            case .tracks:
                guard let playlist = AudioManager.shared.convertPlaylist(self.searchResponse?.results ?? [], source: self.currentSource),
                      playlist.count == (self.searchResponse?.results.count ?? 0)
                else { return }
                
                let track = playlist[indexPath.item]
                if track.needFetchingPlayableLinks {
                    AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                        if let response = updatedTrack.response {
                            self?.searchResponse?.results[indexPath.item] = response
                        }
                        
                        AudioPlayer.shared.play(from: updatedTrack.track, playlist: playlist, position: indexPath.item, isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false))
                        if !(self?.didChangePlaylistInPlayer ?? false) {
                            self?.didChangePlaylistInPlayer = true
                        }
                    }
                } else {
                    AudioPlayer.shared.play(from: track, playlist: playlist, position: indexPath.item, isNewPlaylist: !self.didChangePlaylistInPlayer)
                    if !self.didChangePlaylistInPlayer {
                        self.didChangePlaylistInPlayer = true
                    }
                }
            default:
                return
        }
    }
}
