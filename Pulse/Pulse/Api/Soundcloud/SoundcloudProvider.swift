//
//  SoundcloudProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation
import FriendlyURLSession

final class SoundcloudProvider: BaseRestApiProvider {
    static let shared = SoundcloudProvider()
    
    fileprivate override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
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
