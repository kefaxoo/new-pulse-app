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
}
