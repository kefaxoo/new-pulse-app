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
    
    func fetchAudioLink(trackId: Int, shouldCancelTask: Bool = true, completion: @escaping((String?) -> ())) {
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
                          let maxBitrate = downloadInfo.result.map({ $0.bitrate }).max(),
                          let downloadInfoWithMaxBitrate = downloadInfo.result.first(where: { $0.bitrate == maxBitrate }),
                          let urlComponents = URLComponents(string: downloadInfoWithMaxBitrate.downloadInfoUrl)
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
    
    func trackInfo(id: Int, success: @escaping((YandexMusicTrack) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: YandexMusicApi.track(trackId: id), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let track = response.data?.map(to: YandexMusicBaseResult<YandexMusicTrack>.self) else { return }
                    
                    success(track.result)
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
}
