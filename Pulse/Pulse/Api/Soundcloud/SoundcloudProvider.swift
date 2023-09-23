//
//  SoundcloudProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation
import FriendlyURLSession

final class SoundcloudProvider: BaseRestApiProvider {
    static let shared = SoundcloudProvider(shouldCancelTask: true)
    
    fileprivate override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
    func signIn(success: @escaping((SoundcloudToken) -> ()), failure: @escaping SoundcloudDefualtErrorClosure) {
        urlSession.dataTask(with: URLRequest(type: SoundcloudApi.signIn, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let token = response.data?.map(to: SoundcloudToken.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(token)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, reload: {
                        self?.signIn(success: success, failure: failure)
                    })
            }
        }
    }
    
    func refreshToken(success: @escaping((SoundcloudToken) -> ()), failure: @escaping SoundcloudDefualtErrorClosure) {
        urlSession.dataTask(with: URLRequest(type: SoundcloudApi.refreshToken, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let token = response.data?.map(to: SoundcloudToken.self) else {
                        failure(nil)
                        return
                    }
                
                    success(token)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, reload: {
                        self?.refreshToken(success: success, failure: failure)
                    })
            }
        }
    }
    
    func userInfo(accessToken: String, success: @escaping((SoundcloudUserInfo) -> ()), failure: SoundcloudDefualtErrorClosure? = nil) {
        urlSession.dataTask(
            with: URLRequest(
                type: SoundcloudApi.userInfoWith(
                    accessToken: accessToken
                ), 
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let userInfo = response.data?.map(to: SoundcloudUserInfo.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success(userInfo)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, reload: {
                        self?.userInfo(accessToken: accessToken, success: success, failure: failure)
                    })
            }
        }
    }
    
    func libraryTracks(
        cursor: String? = nil,
        success: @escaping(([SoundcloudTrack], String?) -> ()),
        failure: @escaping SoundcloudDefualtErrorClosure
    ) {
        urlSession.dataTask(
            with: URLRequest(
                type: SoundcloudApi.likedTracks(
                    cursor: cursor
                ),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let response = response.data?.map(to: SoundcloudMain<SoundcloudTrack>.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(response.collection, response.cursor)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, reload: {
                        self?.libraryTracks(success: success, failure: failure)
                    })
            }
        }
    }
    
    func libraryPlaylists(
        cursor: String? = nil,
        success: @escaping(([SoundcloudPlaylist], String?) -> ()),
        failure: @escaping SoundcloudDefualtErrorClosure
    ) {
        urlSession.dataTask(
            with: URLRequest(
                type: SoundcloudApi.likedPlaylists(cursor: cursor),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let response = response.data?.map(to: SoundcloudMain<SoundcloudPlaylist>.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(response.collection, response.cursor)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, reload: { [weak self] in 
                        self?.libraryPlaylists(cursor: cursor, success: success, failure: failure)
                    })
            }
        }
    }
    
    func fetchPlayableLinks(
        id: Int,
        shouldCancelTask: Bool = true,
        success: @escaping((SoundcloudPlayableLinks) -> ()),
        failure: @escaping SoundcloudDefualtErrorClosure
    ) {
        if shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(
                type: SoundcloudApi.playableLink(
                    id: id
                ),
                shouldPrintLog: self.shouldPrintLog
            ), 
            response: { [weak self] response in
                switch response {
                    case .success(let response):
                        guard let playableLinks = response.data?.map(to: SoundcloudPlayableLinks.self) else {
                            failure(nil)
                            return
                        }
                        
                        success(playableLinks)
                    case .failure(let response):
                        self?.parseError(response: response, closure: failure, reload: {
                            self?.fetchPlayableLinks(id: id, shouldCancelTask: shouldCancelTask, success: success, failure: failure)
                        })
                }
            }
        )
    }
    
    func trackInfo(id: Int, success: @escaping((SoundcloudTrack) -> ()), failure: SoundcloudDefualtErrorClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: SoundcloudApi.trackInfo(id: id), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let track = response.data?.map(to: SoundcloudTrack.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success(track)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, reload: {
                        self?.trackInfo(id: id, success: success, failure: failure)
                    })
            }
        }
    }
    
    func likeTrack(id: Int) {
        urlSession.dataTask(with: URLRequest(type: SoundcloudApi.likeTrack(id: id), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success:
                    break
                case .failure(let response):
                    self?.parseError(response: response, closure: nil, reload: {
                        self?.likeTrack(id: id)
                    })
            }
        }
    }
    
    func search(
        query: String,
        searchType: SearchType,
        offset: Int = 0,
        success: @escaping(((SearchResponse) -> ())),
        failure: @escaping SoundcloudDefualtErrorClosure
    ) {
        if shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(
                type: SoundcloudApi.search(
                    type: searchType,
                    query: query,
                    offset: offset
                ),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let searchResponse = response.data?.map(to: SoundcloudMain<SoundcloudTrack>.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(SearchResponse(results: searchResponse.collection))
                case .failure(let response):
                    guard response.statusCode != -1 else { return }
                    
                    self?.parseError(response: response, closure: failure, reload: {
                        self?.search(query: query, searchType: searchType, success: success, failure: failure)
                    })
            }
        }
    }
    
    func userInfo(success: @escaping((SoundcloudUserInfo) -> ()), failure: SoundcloudDefualtErrorClosure? = nil) {
        self.userInfo(accessToken: SettingsManager.shared.soundcloud.accessToken ?? "", success: success, failure: failure)
    }
}

fileprivate extension SoundcloudProvider {
    private func parseError(response: Failure, closure: SoundcloudDefualtErrorClosure?, reload: @escaping(() -> ())) {
        if response.statusCode == 401 {
            self.refreshToken { token in
                SettingsManager.shared.soundcloud.updateTokens(token)
                reload()
            } failure: { [weak self] _ in
                self?.parseError(response: response, closure: closure)
            }
        } else {
            self.parseError(response: response, closure: closure)
        }
    }
    
    private func parseError(response: Failure, closure: SoundcloudDefualtErrorClosure?) {
        response.sendLog()
        if let error = response.error {
            closure?(SoundcloudError(errorDescription: error.localizedDescription))
        } else if let error = response.data?.map(to: SoundcloudError.self) {
            closure?(error)
        } else {
            closure?(nil)
        }
    }
}
