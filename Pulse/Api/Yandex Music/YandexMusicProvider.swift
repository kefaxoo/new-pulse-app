//
//  YandexMusicProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation
import FriendlyURLSession

final class YandexMusicProvider: BaseRestApiProvider {
    static let shared = YandexMusicProvider()
    
    fileprivate init() {
        super.init(shouldPrintLog: AppEnvironment.current.isDebug)
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
    func fetchUserProfileInfo(success: @escaping((YandexAccountInfo) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.userProfileInfo, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let accountInfo = response.data?.map(to: YandexAccountInfo.self) else { return }
                    
                    SettingsManager.shared.yandexMusic.id          = Int(accountInfo.id) ?? 0
                    SettingsManager.shared.yandexMusic.displayName = accountInfo.displayName
                    success(accountInfo)
                case .failure:
                    break
            }
        }
    }
    
    func fetchAccountInfo(success: @escaping((YandexMusicAccountStatus) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.accountInfo, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let accountStatus = response.data?.map(to: YandexMusicBaseResult<YandexMusicAccountStatus>.self) else { return }
                    
                    success(accountStatus.result)
                case .failure:
                    break
            }
        }
    }
    
    func search(query: String, searchType: SearchType, page: Int = 0, success: @escaping((SearchResponse) -> ())) {
        if shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(type: YandexMusicApi.search(query: query, page: page, type: searchType), shouldPrintLog: self.shouldPrintLog),
            response: { response in
                switch response {
                    case .success(let response):
                        guard let search = response.data?.map(to: YandexMusicBaseResult<YandexMusicSearch>.self) else { return }
                        
                        let searchResponse = search.result
                        success(SearchResponse(page: searchResponse.page, results: searchResponse.results, canLoadMore: searchResponse.canLoadMore))
                    case .failure:
                        break
                }
            })
    }
    
    func fetchAudioLink(for track: TrackModel, shouldCancelTask: Bool = true, completion: @escaping((String?) -> ())) {
        self.fetchAudioLink(trackId: track.id, shouldCancelTask: shouldCancelTask, completion: completion)
    }
    
    func fetchAudioLink(trackId: String, shouldCancelTask: Bool = true, completion: @escaping((String?) -> ())) {
        if shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(
                type: YandexMusicApi.fetchAudioLinkStep1(trackId: trackId), 
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let downloadInfo = response.data?.map(to: YandexMusicBaseResult<[YandexMusicDownloadInfo]>.self),
                          let downloadInfoWithBitrate = downloadInfo.result.first(where: {
                              $0.bitrate == SettingsManager.shared.yandexMusic.streamingQuality.rawValue
                          }) ?? downloadInfo.result.first(where: { $0.bitrate == downloadInfo.result.map({ $0.bitrate }).max() ?? 128 }),
                          let urlComponents = URLComponents(string: downloadInfoWithBitrate.downloadInfoUrl)
                    else {
                        completion(nil)
                        return
                    }
                    
                    self?.urlSession.dataTask(
                        with: URLRequest(
                            type: YandexMusicApi.fetchAudioLinkStep2(components: urlComponents),
                            shouldPrintLog: self?.shouldPrintLog ?? false
                        ),
                        response: { response in
                            switch response {
                                case .success(let response):
                                    guard let fileDownloadInfo = response.data?.map(to: YandexMusicFileDownloadInfo.self) else {
                                        completion(nil)
                                        return
                                    }
                                    
                                    completion(fileDownloadInfo.link)
                                case .failure:
                                    completion(nil)
                            }
                        }
                    )
                case .failure:
                    completion(nil)
            }
        }
    }
    
    func trackInfo(id: String, success: @escaping((YandexMusicTrack) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.track(trackId: id), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let track = response.data?.map(to: YandexMusicBaseResult<[YandexMusicTrack]>.self)?.result.first else { return }
                    
                    success(track)
                case .failure:
                    break
            }
        }
    }
    
    func likeTrack(_ track: TrackModel) {
        self.urlSession.dataTask(
            with: URLRequest(type: YandexMusicApi.likeTrack(track: track), shouldPrintLog: self.shouldPrintLog), 
            response: { _ in }
        )
    }
    
    func removeLikeTrack(_ track: TrackModel) {
        self.urlSession.dataTask(
            with: URLRequest(type: YandexMusicApi.removeLikeTrack(track: track), shouldPrintLog: self.shouldPrintLog),
            response: { _ in }
        )
    }
    
    func libraryTracks(offset: Int = 0, success: @escaping(([YandexMusicTrack]) -> ()), failure: @escaping (() -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.likedTracks, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let shortTracksInfo = response.data?.map(to: YandexMusicBaseResult<YandexMusicLibrary>.self)?.result.library.tracks else {
                        failure()
                        return
                    }
                    
                    self?.tracksInfo(ids: shortTracksInfo[offset..<offset + 20].map({ $0.id }), success: success, failure: failure)
                case .failure:
                    failure()
            }
        }
    }
    
    func tracksInfo(ids: [String], success: @escaping(([YandexMusicTrack]) -> ()), failure: (() -> ())? = nil) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.tracks(trackIds: ids), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let tracks = response.data?.map(to: YandexMusicBaseResult<[YandexMusicTrack]>.self) else {
                        failure?()
                        return
                    }
                    
                    success(tracks.result)
                case .failure:
                    failure?()
            }
        }
    }
    
    func fetchArtist(_ artist: ArtistModel, success: @escaping((YandexMusicArtistRoot) -> ()), failure: (() -> ())? = nil) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.artist(artist: artist), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let artist = response.data?.map(to: YandexMusicBaseResult<YandexMusicArtistRoot>.self)?.result else {
                        failure?()
                        return
                    }
                    
                    success(artist)
                case .failure:
                    failure?()
            }
        }
    }
    
    func fetchSearchSuggestions(query: String, success: @escaping((SearchResponse) -> ())) {
        task?.cancel()
        
        task = self.urlSession.returnDataTask(with: URLRequest(type: YandexMusicApi.searchSuggestions(query: query), shouldPrintLog: self.shouldPrintLog)
        ) { response in
            switch response {
                case .success(let response):
                    guard let suggestions = response.data?.map(to: YandexMusicBaseResult<YandexMusicSuggestions>.self)?.result.suggestions else {
                        return
                    }
                    
                    success(SearchResponse(results: suggestions, canLoadMore: false))
                case .failure:
                    break
            }
        }
    }
    
    func fetchSearchHistory(type: SearchType, success: @escaping((SearchResponse) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.searchHistory(type: type), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let history = response.data?.map(to: YandexMusicBaseResult<[ResponseYandexMusicSearchHistoryModel]>.self)?.result else { return }
                    
                    success(SearchResponse(results: history, canLoadMore: false))
                case .failure:
                    break
            }
        }
    }
}
