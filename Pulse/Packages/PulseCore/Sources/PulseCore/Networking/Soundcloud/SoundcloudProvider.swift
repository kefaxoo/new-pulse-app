//
//  SoundcloudProvider.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation
import FriendlyURLSession

public final class SoundcloudProvider: BaseRestApiProvider {
    public static let shared = SoundcloudProvider()
    
    fileprivate override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: AppEnvironment.current.isDebug, shouldCancelTask: false)
    }
    
    public func signIn(completion: @escaping SoundcloudSignCompletion) {
        self.urlSession.dataTask(with: URLRequest(type: SoundcloudApi.signIn, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let token = response.data?.map(to: SoundcloudToken.self) else {
                        completion(nil, SoundcloudError(errorDescription: "Map error"))
                        return
                    }
                    
                    completion(token, nil)
                case .failure(let response):
                    if let error = response.error {
                        completion(nil, SoundcloudError(errorDescription: error.localizedDescription))
                    } else if let error = response.data?.map(to: SoundcloudError.self) {
                        completion(nil, error)
                    }
            }
        }
    }
    
    public func fetchRefreshToken(completion: @escaping SoundcloudSignCompletion) {
        self.urlSession.dataTask(with: URLRequest(type: SoundcloudApi.refreshToken, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let token = response.data?.map(to: SoundcloudToken.self) else {
                        completion(nil, SoundcloudError(errorDescription: "Map error"))
                        return
                    }
                    
                    completion(token, nil)
                case .failure(let response):
                    if let error = response.error {
                        completion(nil, SoundcloudError(errorDescription: error.localizedDescription))
                    } else if let error = response.data?.map(to: SoundcloudError.self) {
                        completion(nil, error)
                    }
            }
        }
    }
    
    public func fetchUserInfo(accessToken: String, success: @escaping((_ userInfo: SoundcloudUserInfo) -> ()), failure: SoundcloudErrorCompletion? = nil) {
        self.urlSession.dataTask(with: URLRequest(type: SoundcloudApi.userInfoWith(accessToken: accessToken), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let userInfo = response.data?.map(to: SoundcloudUserInfo.self) else {
                        failure?(SoundcloudError(errorDescription: "Map error"))
                        return
                    }
                    
                    success(userInfo)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, retryClosure: {
                        self?.fetchUserInfo(accessToken: SettingsManager.shared.soundcloud.accessToken ?? accessToken, success: success, failure: failure)
                    })
            }
        }
    }
}

private extension SoundcloudProvider {
    func parseError(response: Failure, closure: SoundcloudErrorCompletion?, retryClosure: EmptyCompletion? = nil) {
        if response.statusCode == 401 {
            self.fetchRefreshToken { tokens, error in
                guard let tokens,
                      SettingsManager.shared.soundcloud.saveOrUpdateTokens(tokens)
                else { return }
                
                retryClosure?()
            }
        } else if let error = response.error {
            closure?(SoundcloudError(errorDescription: error.localizedDescription))
        } else if let error = response.data?.map(to: SoundcloudError.self) {
            closure?(error)
        }
    }
}
