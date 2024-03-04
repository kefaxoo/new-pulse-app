//
//  SearchPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

protocol SearchPresenterDelegate: AnyObject {
    func setupServiceSegmentedControl(items: [String], selectedIndex: Int)
    func setupTypeSegmentedControl(items: [String], selectedIndex: Int)
    func reloadData(scrollToTop: Bool)
    func dismissKeyboard()
    func appendNewCells(indexPaths: [IndexPath])
    func setQuery(_ query: String)
}

extension SearchPresenterDelegate {
    func reloadData(scrollToTop: Bool = true) {
        self.reloadData(scrollToTop: scrollToTop)
    }
}

final class SearchPresenter: NSObject, BasePresenter {
    private var services: [ServiceType] {
        return ServiceType.searchController
    }
    
    private var currentServices = [ServiceType]()
    private var currentTypes = [SearchType]()
    private var query = ""
    
    private(set) var currentService: ServiceType = .none
    private var currentSource: SourceType {
        return self.currentService.source
    }
    
    private(set) var currentType: SearchType = .none
    private var searchResponse: SearchResponse?
    
    private var isResultsLoading = false
    private var didChangePlaylistInPlayer = false
    
    private var isMovingFromNavigationController = false
    
    private var isQueryActive = false
    
    private var isSeachSuggestions = false
    
    weak var delegate: SearchPresenterDelegate?
    
    var resultsCount: Int {
        return searchResponse?.results.count ?? 0
    }
    
    func viewDidLoad() {
        self.currentServices = self.services
        self.delegate?.setupServiceSegmentedControl(items: services.map({ $0.title }), selectedIndex: 0)
        guard !services.isEmpty else { return }
        
        self.currentService = services[0]
        let searchTypes = SearchType.types(for: services[0])
        self.currentTypes = searchTypes
        self.delegate?.setupTypeSegmentedControl(items: searchTypes.map({ $0.title }), selectedIndex: 0)
        
        guard !searchTypes.isEmpty else { return }
        
        self.currentType = searchTypes[0]
    }
    
    func viewWillAppear(_ currentServiceIndex: Int = 0, _ currentTypeIndex: Int = 0) {
        guard !self.isMovingFromNavigationController else { return }
        
        self.setupSegmentedControls(currentServiceIndex, currentTypeIndex)
        self.isMovingFromNavigationController = false
        self.search()
    }
    
    func textDidChange(_ text: String) {
        if self.currentService == .yandexMusic {
            self.isSeachSuggestions = true
        }
        
        if text.isEmpty {
            self.searchHistory()
            return
        }
        
        self.query = text
        if self.isQueryActive {
            perform(#selector(search), with: nil, afterDelay: 1)
        } else {
            self.search()
        }
    }
    
    func setupSegmentedControls(_ currentServiceIndex: Int = 0, _ currentTypeIndex: Int = 0) {
        self.delegate?.setupServiceSegmentedControl(items: services.map({ $0.title }), selectedIndex: currentServiceIndex)
        guard !services.isEmpty,
              services.count > currentServiceIndex
        else { return }
        
        self.currentService = services[currentServiceIndex]
        let searchTypes = SearchType.types(for: self.currentService)
        self.delegate?.setupTypeSegmentedControl(items: searchTypes.map({ $0.title }), selectedIndex: currentTypeIndex)
        guard !searchTypes.isEmpty,
              searchTypes.count > currentTypeIndex
        else { return }
        
        self.currentType = searchTypes[currentTypeIndex]
    }
    
    func serviceDidChange(index: Int) {
        self.currentService = services[index]
        self.setupSegmentedControls(index)
        self.textDidChange(self.query)
        
        if self.query.isEmpty {
            self.searchHistory()
        }
    }
    
    func typeDidChange(index: Int) {
        self.currentType = SearchType.types(for: self.currentService)[index]
        self.textDidChange(self.query)
    }
    
    @objc func search() {
        self.isQueryActive = true
        guard !self.query.isEmpty else {
            self.isQueryActive = false
            MuffonProvider.shared.cancelTask()
            SoundcloudProvider.shared.cancelTask()
            YandexMusicProvider.shared.cancelTask()
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            return
        }
        
        self.didChangePlaylistInPlayer = false
        if !self.isSeachSuggestions {
            MainCoordinator.shared.currentViewController?.presentSpinner()
        }
        
        switch self.currentService.source {
            case .muffon:
                MuffonProvider.shared.search(query: query, in: self.currentService, type: self.currentType) { [weak self] response in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self?.searchResponse = response
                    self?.isQueryActive = false
                    self?.delegate?.reloadData()
                } failure: { [weak self] in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(error: Localization.Lines.unknownError.localization(with: "Muffon"), system: .iOS16AppleMusic)
                    self?.isQueryActive = false
                }
            case .soundcloud:
                SoundcloudProvider.shared.search(query: query, searchType: self.currentType) { [weak self] response in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self?.searchResponse = response
                    self?.isQueryActive = false
                    self?.delegate?.reloadData()
                } failure: { [weak self] error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(
                        error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                        system: .iOS16AppleMusic
                    )
                    
                    self?.isQueryActive = false
                }
            case .yandexMusic:
                if self.isSeachSuggestions {
                    YandexMusicProvider.shared.fetchSearchSuggestions(query: query) { [weak self] response in
                        self?.searchResponse = response
                        self?.isQueryActive = false
                        self?.delegate?.reloadData(scrollToTop: true)
                    }
                } else {
                    YandexMusicProvider.shared.search(query: query, searchType: self.currentType) { [weak self] response in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        self?.searchResponse = response
                        self?.isQueryActive = false
                        self?.delegate?.reloadData()
                    }
                }
            default:
                self.isQueryActive = false
                MainCoordinator.shared.currentViewController?.dismissSpinner()
        }
    }
    
    func searchHistory() {
        self.searchResponse = nil
        self.delegate?.reloadData()
        MuffonProvider.shared.cancelTask()
        SoundcloudProvider.shared.cancelTask()
        YandexMusicProvider.shared.cancelTask()
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        
        self.isQueryActive = true
        switch self.currentService {
            case .yandexMusic:
                self.isSeachSuggestions = false
                YandexMusicProvider.shared.fetchSearchHistory(type: self.currentType) { [weak self] response in
                    self?.searchResponse = response
                    self?.isQueryActive = false
                    self?.delegate?.reloadData(scrollToTop: true)
                }
            default:
                self.isQueryActive = false
                return
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
                        let indexPaths = self?.indexPaths(for: searchResponse)
                        self?.searchResponse?.addResults(searchResponse)
                        self?.delegate?.appendNewCells(indexPaths: indexPaths ?? [])
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
                    ) { [weak self] searchResponse in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        let indexPaths = self?.indexPaths(for: searchResponse)
                        self?.searchResponse?.addResults(searchResponse)
                        self?.delegate?.appendNewCells(indexPaths: indexPaths ?? [])
                        self?.isResultsLoading = false
                    } failure: { [weak self] _ in
                        self?.searchResponse?.cannotLoadMore()
                        self?.isResultsLoading = false
                    }
                case .yandexMusic:
                    YandexMusicProvider.shared.search(
                        query: self.query,
                        searchType: self.currentType,
                        page: ((self.searchResponse?.page ?? 0) + 1)
                    ) { [weak self] searchResponse in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        let indexPaths = self?.indexPaths(for: searchResponse)
                        self?.searchResponse?.addResults(searchResponse)
                        self?.delegate?.appendNewCells(indexPaths: indexPaths ?? [])
                        self?.isResultsLoading = false
                    }
                default:
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    self.isResultsLoading = false
                    self.searchResponse?.cannotLoadMore()
            }
        }
    }
    
    func trackIndex(for track: TrackModel) -> Int? {
        guard self.currentType == .tracks else { return nil }
        
        if self.query.isEmpty,
           self.currentService.isHistoryAvailable {
            switch currentService {
                case .yandexMusic:
                    guard let yandexMusicTracks = self.searchResponse?.results(of: YandexMusicSearchHistory.self)?
                        .compactMap({ $0.track }) else { return nil }
                    
                    return yandexMusicTracks.map({ TrackModel($0) }).firstIndex(where: { $0 == track })
                default:
                    return nil
            }
        }
        
        switch self.currentService.source {
            case .muffon:
                return self.searchResponse?.results(of: MuffonTrack.self)?.map({ TrackModel($0) }).firstIndex(where: { $0 == track })
            case .soundcloud:
                return self.searchResponse?.results(of: SoundcloudTrack.self)?.map({ TrackModel($0) }).firstIndex(where: { $0 == track })
            case .yandexMusic:
                return self.searchResponse?.results(of: YandexMusicTrack.self)?.map({ TrackModel($0) }).firstIndex(where: { $0 == track })
            default:
                return nil
        }
    }
    
    func indexPaths(for searchResponse: SearchResponse) -> [IndexPath] {
        let begin = self.searchResponse?.results.count ?? 0
        let end = begin + searchResponse.results.count
        var indexPaths = [IndexPath]()
        for i in begin..<end {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        
        return indexPaths
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension SearchPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        if self.query.isEmpty,
           self.currentService.isHistoryAvailable {
            switch self.currentService {
                case .yandexMusic:
                    guard let type = (self.searchResponse?.results[indexPath.item] as? YandexMusicSearchHistory)?
                        .type else { return UITableViewCell() }
                    
                    return self.setupCell(tableView.dequeueReusableCell(withIdentifier: type.id, for: indexPath), at: indexPath)
                default:
                    return UITableViewCell()
            }
        }
        
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: self.isSeachSuggestions ? SearchSuggestionTableViewCell.id : self.currentType.id, for: indexPath), at: indexPath)
    }
    
    func setupCellForHistory(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        switch self.currentService {
            case .yandexMusic:
                guard let historyItem = self.searchResponse?.results[indexPath.row] as? YandexMusicSearchHistory else { return UITableViewCell() }
                
                switch historyItem.type {
                    case .tracks:
                        guard let yandexMusicTrack = historyItem.track else { return UITableViewCell() }
                        
                        let track = TrackModel(yandexMusicTrack)
                        (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track), isSearchController: true)
                    default:
                        return UITableViewCell()
                }
                
                return cell
            default:
                return UITableViewCell()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        guard self.currentType != .none else { return UITableViewCell() }
        
        if self.isSeachSuggestions {
            guard let suggestion = self.searchResponse?.results[indexPath.item] as? String else { return UITableViewCell() }
            
            (cell as? SearchSuggestionTableViewCell)?.setText(suggestion)
            return cell
        }
        
        if self.query.isEmpty {
            return self.setupCellForHistory(cell, at: indexPath)
        }
        
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
                    case .yandexMusic:
                        guard let yandexMusicTrack = self.searchResponse?.result(
                            at: indexPath, of: YandexMusicTrack.self
                        ) else { return UITableViewCell() }
                        
                        track = TrackModel(yandexMusicTrack)
                    default:
                        return UITableViewCell()
                }
                
                (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track), isSearchController: true)
            case .playlists:
                let playlist: PlaylistModel
                switch self.currentSource {
                    case .soundcloud:
                        guard let soundcloudPlaylist = self.searchResponse?.result(
                            at: indexPath,
                            of: SoundcloudPlaylist.self
                        ) else { return UITableViewCell() }
                        
                        playlist = PlaylistModel(soundcloudPlaylist)
                    default:
                        return UITableViewCell()
                }
                
                (cell as? PlaylistTableViewCell)?.setupCell(playlist)
            default:
                return UITableViewCell()
        }
        
        return cell
    }
    
    func didSelectRowHistory(at indexPath: IndexPath) {
        switch self.currentService {
            case .yandexMusic:
                guard let historyItem = self.searchResponse?.results[indexPath.row] as? YandexMusicSearchHistory else { return }
                
                switch historyItem.type {
                    case .tracks:
                        guard let playlistRaw = (self.searchResponse?.results as? [YandexMusicSearchHistory])?
                            .filter({ $0.type == .tracks }).map({ $0.track }),
                              let playlist = AudioManager.shared.convertPlaylist(playlistRaw, source: self.currentSource),
                              playlist.count == (self.searchResponse?.results.count ?? 0)
                        else { return }
                        
                        let track = playlist[indexPath.item]
                        if track.needFetchingPlayableLinks {
                            AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                                self?.play(
                                    from: updatedTrack.track,
                                    in: playlist,
                                    at: indexPath.row,
                                    isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false)
                                )
                            }
                        } else {
                            self.play(from: track, in: playlist, at: indexPath.item, isNewPlaylist: !self.didChangePlaylistInPlayer)
                        }
                    default:
                        break
                }
            default:
                break
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        self.delegate?.dismissKeyboard()
        if self.currentService == .yandexMusic,
           self.isSeachSuggestions {
            self.isSeachSuggestions = false
            if let suggestion = self.searchResponse?.results[indexPath.row] as? String {
                self.delegate?.setQuery(suggestion)
            }
            
            self.search()
        }
        
        if self.query.isEmpty,
           self.currentService.isHistoryAvailable {
            self.didSelectRowHistory(at: indexPath)
        }
        
        switch self.currentType {
            case .tracks:
                guard let playlist = AudioManager.shared.convertPlaylist(self.searchResponse?.results ?? [], source: self.currentSource),
                      playlist.count == (self.searchResponse?.results.count ?? 0)
                else { return }
                
                let track = playlist[indexPath.item]
                if track.needFetchingPlayableLinks {
                    AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                        if let response = updatedTrack.response {
                            switch self?.currentSource {
                                case .soundcloud:
                                    guard let streamingLink = (response as? SoundcloudPlayableLinks)?.streamingLink else { break }
                                    
                                    (self?.searchResponse?.results[indexPath.item] as? SoundcloudTrack)?.playableLink = streamingLink
                                case .muffon:
                                    self?.searchResponse?.results[indexPath.item] = response
                                default:
                                    break
                            }
                        }
                        
                        self?.play(
                            from: updatedTrack.track, in: playlist, at: indexPath.item, isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false)
                        )
                    }
                } else {
                    self.play(from: track, in: playlist, at: indexPath.item, isNewPlaylist: !self.didChangePlaylistInPlayer)
                }
            case .playlists:
                let type: LibraryControllerType
                let playlist: PlaylistModel
                switch self.currentSource {
                    case .soundcloud:
                        guard let soundcloudPlaylist = self.searchResponse?.result(at: indexPath, of: SoundcloudPlaylist.self) else { return }
                        
                        type = .soundcloud
                        playlist = PlaylistModel(soundcloudPlaylist)
                    default:
                        return
                }
                
                self.isMovingFromNavigationController = true
                MainCoordinator.shared.pushPlaylistViewController(type: type, playlist: playlist)
            default:
                return
        }
    }
}

// MARK: -
// MARK: Audio Player methods
fileprivate extension SearchPresenter {
    func play(from track: TrackModel, in playlist: [TrackModel], at position: Int, isNewPlaylist: Bool) {
        AudioPlayer.shared.play(from: track, playlist: playlist, position: position, isNewPlaylist: isNewPlaylist)
        
        if !self.didChangePlaylistInPlayer {
            self.didChangePlaylistInPlayer = true
        }
    }
}
