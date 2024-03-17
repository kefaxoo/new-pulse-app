//
//  SearchViewModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.03.24.
//

import UIKit

final class SearchViewModel: NSObject {
    private var services: [ServiceType] {
        return ServiceType.searchController
    }
    
    private var currentServices: Dynamic<[ServiceType]> = Dynamic([])
    private var currentService: ServiceType = .none {
        didSet {
            self.currentTypes.value = SearchType.types(for: self.currentService)
        }
    }

    private var currentTypes: Dynamic<[SearchType]> = Dynamic([])
    
    private var currentSource: SourceType {
        return self.currentService.source
    }
    
    private var searchResponse: Dynamic<SearchResponse?> = Dynamic(nil)
    
    private var query = ""
    private var isQueryActive = false
    private var viewQuery = Dynamic<String>("")
    
    private var isMovingFromNavigationController = false
    
    private var didChangePlaylistInPlayer = false
    
    private var shouldShowContentUnavailableView = Dynamic<Bool>(true)
    
    private var indexPaths = Dynamic<[IndexPath]>([])
    
    private let coordinator: SearchCoordinator
    
    var currentServiceIndex: Int {
        return self.currentServices.value.firstIndex(of: self.currentService) ?? 0
    }
    
    var currentType: SearchType = .none
    
    var currentTypeIndex: Int {
        return self.currentTypes.value.firstIndex(of: self.currentType) ?? 0
    }
    
    var resultsCount: Int {
        return self.searchResponse.value?.results.count ?? 0
    }
    
    var shouldScrollToTop = false
    
    var isSearchSuggestions = false
    
    var isResultsLoading = false
    
    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }
}

// MARK: -
// MARK: Lifecycle
extension SearchViewModel {
    func viewDidLoad() {
        self.currentService = self.services.first ?? .none
        self.currentServices.value = self.services
        
        self.currentTypes.value = SearchType.types(for: self.currentService)
        self.currentType = self.currentTypes.value.first ?? .none
    }
    
    func viewWillAppear() {
        guard !self.isMovingFromNavigationController else { return }
        
        self.isMovingFromNavigationController = false
        self.updateSegmentedControlsIfNeeded()
    }
}

// MARK: -
// MARK: Bindings
extension SearchViewModel {
    func setupCurrentServicesBinding(_ listener: Dynamic<[ServiceType]>.Listener?) {
        self.currentServices.bind(listener)
    }
    
    func setupCurrentTypesBinding(_ listener: Dynamic<[SearchType]>.Listener?) {
        self.currentTypes.bind(listener)
    }
    
    func setupSearchResponseBinding(_ listener: Dynamic<SearchResponse?>.Listener?) {
        self.searchResponse.bind(listener)
    }
    
    func setupViewQueryBinding(_ listener: Dynamic<String>.Listener?) {
        self.viewQuery.bind(listener)
    }
    
    func setupShouldShowContentUnavailableView(_ listener: Dynamic<Bool>.Listener?) {
        self.shouldShowContentUnavailableView.bind(listener)
    }
    
    func setupIndexPaths(_ listener: Dynamic<[IndexPath]>.Listener?) {
        self.indexPaths.bind(listener)
    }
}

// MARK: -
// MARK: Public
extension SearchViewModel {
    func serviceDidChange(index: Int) {
        self.currentService = self.currentServices.value[index]
        self.currentTypes.value = SearchType.types(for: self.currentService)
        self.currentType = self.currentTypes.value.first ?? .none
        self.shouldScrollToTop = true
        self.search()
    }
    
    func searchTypeDidChange(index: Int) {
        self.currentType = self.currentTypes.value[index]
        self.shouldScrollToTop = true
        self.search()
    }
    
    func searchFor(query: String) {
        self.query = query
        if isQueryActive {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: nil)
        } else if query.isEmpty {
            self.searchResponse.value = nil
        }
        
        self.perform(#selector(search), with: nil)
    }
    
    func trackIndex(for track: TrackModel) -> Int? {
        guard self.currentType == .tracks else { return nil }
        
        if self.query.isEmpty,
           self.currentSource.isHistoryAvailable {
            switch currentService {
                case .yandexMusic:
                    return (self.searchResponse.value?.results as? [YandexMusicSearchHistory])?
                        .compactMap({ $0.track })
                        .map({ TrackModel($0) })
                        .firstIndex(of: track)
                default:
                    return nil
            }
        }
        
        switch self.currentSource {
            case .muffon:
                return (self.searchResponse.value?.results as? [MuffonTrack])?.map({ TrackModel($0) }).firstIndex(of: track)
            case .soundcloud:
                return (self.searchResponse.value?.results as? [SoundcloudTrack])?.map({ TrackModel($0) }).firstIndex(of: track)
            case .yandexMusic:
                return (self.searchResponse.value?.results as? [YandexMusicTrack])?.map({ TrackModel($0) }).firstIndex(of: track)
            default:
                return nil
        }
    }
    
    func track(at indexPath: IndexPath) -> TrackModel? {
        guard self.currentType == .tracks,
              let result = self.searchResponse.value?.results[indexPath.row]
        else { return nil }
        
        return switch self.currentSource {
            case .muffon:
                if let muffonTrack = result as? MuffonTrack {
                    TrackModel(muffonTrack)
                } else {
                    nil
                }
            case .soundcloud:
                if let soundcloudTrack = result as? SoundcloudTrack {
                    TrackModel(soundcloudTrack)
                } else {
                    nil
                }
            case .yandexMusic:
                if let yandexMusicTrack = result as? YandexMusicTrack {
                    TrackModel(yandexMusicTrack)
                } else if let yandexMusicTrack = (result as? YandexMusicSearchHistory)?.track {
                    TrackModel(yandexMusicTrack)
                } else {
                    nil
                }
            default:
                nil
        }
    }
}

// MARK: -
// MARK: Private
private extension SearchViewModel {
    func updateSegmentedControlsIfNeeded() {
        var shouldUpdateResponse = false
        if self.services != self.currentServices.value {
            self.currentServices.value = self.services
            shouldUpdateResponse = true
        }
        
        let types = SearchType.types(for: self.currentService)
        if self.currentTypes.value != types {
            self.currentTypes.value = types
            shouldUpdateResponse = true
        }
        
        if shouldUpdateResponse {
            self.search()
        }
    }
    
    @objc func search() {
        self.isQueryActive = true
        if self.query.isEmpty {
            self.isQueryActive = false
            MuffonProvider.shared.cancelTask()
            SoundcloudProvider.shared.cancelTask()
            YandexMusicProvider.shared.cancelTask()
            if self.currentSource.isHistoryAvailable {
                self.searchResponse.value = nil
                self.isQueryActive = true
                switch self.currentService {
                    case .yandexMusic:
                        self.isSearchSuggestions = false
                        YandexMusicProvider.shared.fetchSearchHistory(type: self.currentType) { [weak self] response in
                            self?.shouldShowContentUnavailableView.value = false
                            self?.applyResponse(response)
                        }
                    default:
                        self.isQueryActive = false
                }
            }
            
            return
        }
        
        self.didChangePlaylistInPlayer = false
        if !self.isSearchSuggestions {
            MainCoordinator.shared.currentViewController?.presentSpinner()
        }
        
        switch self.currentService.source {
            case .muffon:
                MuffonProvider.shared.search(query: query, in: self.currentService, type: self.currentType) { [weak self] response in
                    self?.applyResponse(response)
                } failure: {
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(error: Localization.Lines.unknownError.localization(with: "Muffon"), system: .iOS16AppleMusic)
                    self.isQueryActive = false
                }
            case .soundcloud:
                SoundcloudProvider.shared.search(query: query, searchType: self.currentType) { [weak self] response in
                    self?.applyResponse(response)
                } failure: { [weak self] error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(
                        error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                        system: .iOS16AppleMusic
                    )
                    
                    self?.isQueryActive = false
                }
            case .yandexMusic:
                if self.isSearchSuggestions {
                    YandexMusicProvider.shared.fetchSearchSuggestions(query: query) { [weak self] response in
                        self?.applyResponse(response)
                    }
                } else {
                    YandexMusicProvider.shared.search(query: query, searchType: self.currentType) { [weak self] response in
                        self?.isSearchSuggestions = false
                        self?.applyResponse(response)
                    }
                }
            default:
                self.isQueryActive = false
                MainCoordinator.shared.currentViewController?.dismissSpinner()
        }
    }
    
    func applyResponse(_ response: SearchResponse) {
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        self.shouldScrollToTop = true
        self.searchResponse.value = response
        self.isQueryActive = false
    }
    
    func play(from track: TrackModel, in playlist: [TrackModel], at position: Int, isNewPlaylist: Bool) {
        AudioPlayer.shared.play(from: track, playlist: playlist, position: position, isNewPlaylist: isNewPlaylist)
        
        self.didChangePlaylistInPlayer = true
    }
}

// MARK: -
// MARK: Table View
extension SearchViewModel {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        if self.query.isEmpty,
           self.currentSource.isHistoryAvailable {
            switch self.currentService {
                case .yandexMusic:
                    let yandexMusicSearchHistory = self.searchResponse.value?.result(at: indexPath, of: YandexMusicSearchHistory.self)
                    guard let type = yandexMusicSearchHistory?.type else { return UITableViewCell() }
                    
                    return self.setupCell(tableView.dequeueReusableCell(withIdentifier: type.id, for: indexPath), at: indexPath)
                default:
                    return UITableViewCell()
            }
        }
        
        let isSearchSuggestions = self.isSearchSuggestions && self.currentSource.isSearchSuggestionsAvailable
        
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: isSearchSuggestions ? SearchSuggestionTableViewCell.id  : self.currentType.id, for: indexPath), at: indexPath)
    }
    
    private func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        guard self.currentType != .none else { return UITableViewCell() }
        
        if self.isSearchSuggestions,
           self.currentSource.isSearchSuggestionsAvailable {
            guard let suggestion = self.searchResponse.value?.results[indexPath.item] as? String else { return cell }
            
            (cell as? SearchSuggestionTableViewCell)?.setText(suggestion)
            return cell
        }
        
        switch self.currentType {
            case .tracks:
                let track: TrackModel? = switch self.currentSource {
                    case .muffon:
                        if let muffonTrack = self.searchResponse.value?.results[indexPath.item] as? MuffonTrack {
                            TrackModel(muffonTrack)
                        } else {
                            nil
                        }
                    case .soundcloud:
                        if let soundcloudTrack = self.searchResponse.value?.results[indexPath.item] as? SoundcloudTrack {
                            TrackModel(soundcloudTrack)
                        } else {
                            nil
                        }
                    case .yandexMusic:
                        if let yandexMusicTrack = self.searchResponse.value?.results[indexPath.item] as? YandexMusicTrack {
                            TrackModel(yandexMusicTrack)
                        } else if let yandexMusicTrack = (self.searchResponse.value?.results[indexPath.item] as? YandexMusicSearchHistory)?.track {
                            TrackModel(yandexMusicTrack)
                        } else {
                            nil
                        }
                    default:
                        nil
                }
                
                guard let track else { return cell }
                
                (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track), isSearchController: true)
            case .playlists:
                let playlist: PlaylistModel? = switch self.currentSource {
                    case .soundcloud:
                        if let soundcloudPlaylist = self.searchResponse.value?.results[indexPath.item] as? SoundcloudPlaylist {
                            PlaylistModel(soundcloudPlaylist)
                        } else {
                            nil
                        }
                    default:
                        nil
                }
                
                guard let playlist else { return cell }
                
                (cell as? PlaylistTableViewCell)?.setupCell(playlist)
            default:
                return cell
        }
        
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        if self.query.isEmpty,
           self.currentSource.isHistoryAvailable {
            switch self.currentService {
                case .yandexMusic:
                    guard let historyItem = self.searchResponse.value?.results[indexPath.row] as? YandexMusicSearchHistory else { return }
                    
                    switch historyItem.type {
                        case .tracks:
                            let searchHistory = self.searchResponse.value?.results as? [YandexMusicSearchHistory]
                            guard let playlist = searchHistory?.filter({ $0.type == .tracks }).map({ $0.track }) else { return }
                            
                            self.didSelectTrack(playlistRaw: playlist, at: indexPath)
                        default:
                            return
                    }
                default:
                    return
            }
            
            return
        }
        
        if self.isSearchSuggestions,
           self.currentSource.isSearchSuggestionsAvailable {
            self.isSearchSuggestions = false
            if let suggestion = self.searchResponse.value?.results[indexPath.row] as? String {
                self.query = suggestion
                self.viewQuery.value = suggestion
            }
            
            self.search()
            return
        }
        
        switch self.currentType {
            case .tracks:
                self.didSelectTrack(playlistRaw: self.searchResponse.value?.results ?? [], at: indexPath)
            case .playlists:
                let type: LibraryControllerType
                let playlist: PlaylistModel
                switch self.currentSource {
                    case .soundcloud:
                        guard let soundcloudPlaylist = self.searchResponse.value?.results[indexPath.item] as? SoundcloudPlaylist else { return }
                        
                        type = .soundcloud
                        playlist = PlaylistModel(soundcloudPlaylist)
                    default:
                        return
                }
                
                self.isMovingFromNavigationController = true
                self.coordinator.pushPlaylistViewController(type: type, playlist: playlist)
            default:
                return
        }
    }
    
    private func didSelectTrack(playlistRaw: [Decodable], at indexPath: IndexPath) {
        guard let playlist = AudioManager.shared.convertPlaylist(playlistRaw, source: self.currentSource),
              playlist.count == playlistRaw.count
        else { return }
        
        let track = playlist[indexPath.item]
        if track.needFetchingPlayableLinks {
            AudioManager.shared.getPlayableLink(for: track) { [weak self] updatedTrack in
                if let response = updatedTrack.response {
                    switch self?.currentSource {
                        case .soundcloud:
                            guard let streamingLink = (response as? SoundcloudPlayableLinks)?.streamingLink else { break }
                            
                            (self?.searchResponse.value?.results[indexPath.item] as? SoundcloudTrack)?.playableLink = streamingLink
                        case .muffon:
                            self?.searchResponse.value?.results[indexPath.item] = response
                        default:
                            break
                    }
                }
                
                self?.play(from: updatedTrack.track, in: playlist, at: indexPath.item, isNewPlaylist: !(self?.didChangePlaylistInPlayer ?? false))
            }
        } else {
            self.play(from: track, in: playlist, at: indexPath.item, isNewPlaylist: !self.didChangePlaylistInPlayer)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height,
              !self.isResultsLoading,
              resultsCount > 0,
              let searchResponse = searchResponse.value,
              searchResponse.canLoadMore
        else { return }
        
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
                    self?.appendNewResults(response: searchResponse)
                } failure: { [weak self] in
                    self?.cannotLoadMore()
                }
            case .soundcloud:
                SoundcloudProvider.shared.search(
                    query: self.query,
                    searchType: self.currentType,
                    offset: self.resultsCount
                ) { [weak self] searchResponse in
                    self?.appendNewResults(response: searchResponse)
                } failure: { [weak self] _ in
                    self?.cannotLoadMore()
                }
            case .yandexMusic:
                YandexMusicProvider.shared.search(
                    query: self.query,
                    searchType: self.currentType,
                    page: searchResponse.page + 1
                ) { [weak self] searchResponse in
                    self?.appendNewResults(response: searchResponse)
                }
            default:
                self.cannotLoadMore()
        }
    }
    
    private func indexPaths(forResponse response: SearchResponse) -> [IndexPath] {
        let begin = self.resultsCount
        let end = begin + response.results.count
        var indexPaths = [IndexPath]()
        for i in begin..<end {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        
        return indexPaths
    }
    
    private func appendNewResults(response: SearchResponse) {
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        let indexPaths = self.indexPaths(forResponse: response)
        self.searchResponse.value?.addResults(response)
        self.indexPaths.value = indexPaths
        self.isResultsLoading = false
    }
    
    private func cannotLoadMore() {
        MainCoordinator.shared.currentViewController?.dismissSpinner()
        self.searchResponse.value?.cannotLoadMore()
        self.isResultsLoading = false
    }
}
