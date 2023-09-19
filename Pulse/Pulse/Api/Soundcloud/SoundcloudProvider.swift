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
                    self?.parseError(response: response, closure: failure)
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
                    self?.parseError(response: response, closure: failure)
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
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func libraryTracks(success: @escaping(([SoundcloudTrack]) -> ()), failure: @escaping SoundcloudDefualtErrorClosure) {
        urlSession.dataTask(with: URLRequest(type: SoundcloudApi.likedTracks, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let tracks = response.data?.map(to: SoundcloudMain<SoundcloudTrack>.self)?.collection else {
                        failure(nil)
                        return
                    }
                    
                    success(tracks)
                case .failure(let response):
                    self.parseError(response: response, closure: failure)
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
                        self?.parseError(response: response, closure: failure)
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
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func likeTrack(id: Int) {
        urlSession.dataTask(with: URLRequest(type: SoundcloudApi.likeTrack(id: id), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success:
                    break
                case .failure(let response):
                    self?.parseError(response: response, closure: nil)
            }
        }
    }
    
    func search(
        query: String,
        searchType: SearchType,
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
                    query: query
                ),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { response in
            switch response {
                case .success(let response):
                    guard let searchResponse = response.data?.map(to: SoundcloudMain<SoundcloudTrack>.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(SearchResponse(results: searchResponse.collection))
                case .failure(let response):
                    guard response.statusCode != -1 else { return }
                    
                    self.parseError(response: response, closure: failure)
            }
        }
    }
    
    func userInfo(success: @escaping((SoundcloudUserInfo) -> ()), failure: SoundcloudDefualtErrorClosure? = nil) {
        self.userInfo(accessToken: SettingsManager.shared.soundcloud.accessToken ?? "", success: success, failure: failure)
    }
}

fileprivate extension SoundcloudProvider {
    func parseError(response: Failure, closure: SoundcloudDefualtErrorClosure?) {
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