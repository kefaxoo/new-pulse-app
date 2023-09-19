//
//  PulseProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import FriendlyURLSession

final class PulseProvider: BaseRestApiProvider {
    static let shared = PulseProvider()
    
    override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func createUser(credentials: Credentials, success: @escaping((PulseCreateUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.createUser(credentials: credentials),
                decodeToHttp: true, 
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let createUser = response.data?.map(to: PulseCreateUser.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(createUser)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func loginUser(
        credentials: Credentials,
        success: @escaping((PulseLoginUser) -> ()),
        failure: @escaping PulseDefaultErrorClosure,
        verifyClosure: @escaping((PulseLoginWithCode) -> ())
    ) {
        self.urlSession.dataTask(with: URLRequest(
            type: PulseApi.loginUser(credentials: credentials),
            decodeToHttp: true,
            shouldPrintLog: self.shouldPrintLog
        )) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let loginUser = response.data?.map(to: PulseLoginUser.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(loginUser)
                case .failure(let response):
                    guard response.statusCode == 425,
                          let verifyError = response.data?.map(to: PulseLoginWithCode.self)
                    else {
                        self?.parseError(response: response, closure: failure)
                        return
                    }
                    
                    verifyClosure(verifyError)
            }
        }
    }
    
    func resetPassword(credentials: Credentials, success: @escaping((PulseVerificationCode) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.resetPassword(credentials: credentials),
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let verificationCode = response.data?.map(to: PulseVerificationCode.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(verificationCode)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func accessToken(success: @escaping((PulseLoginUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.accessToken,
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let loginUser = response.data?.map(to: PulseLoginUser.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(loginUser)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func getTopCovers(success: @escaping(([PulseCover]) -> ()), failure: EmptyClosure? = nil) {
        self.urlSession.dataTask(
            with: URLRequest(type: PulseApi.topCovers(country: NetworkManager.shared.country), shouldPrintLog: self.shouldPrintLog)
        ) { response in
            switch response {
                case .success(let response):
                    guard let covers = response.data?.map(to: [PulseCoverInfo].self) else {
                        failure?()
                        return
                    }
                    
                    success(covers.map({ $0.cover }))
                case .failure(let response):
                    response.sendLog()
                    failure?()
                    return
            }
        }
    }
    
    func sendLog(_ model: LogModel, success: ((PulseSuccess) -> ())? = nil, failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.log(
                    log: model.getFullLog
                ),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let model = response.data?.map(to: PulseSuccess.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success?(model)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func syncTrack(
        _ track: TrackModel,
        success: ((PulseSuccess) -> ())? = nil,
        failure: PulseDefaultErrorClosure? = nil,
        trackInLibraryClosure: (() -> ())? = nil
    ) {
        urlSession.dataTask(with: URLRequest(type: PulseApi.syncTrack(track), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let successModel = response.data?.map(to: PulseSuccess.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success?(successModel)
                case .failure(let response):
                    if response.statusCode == 409 {
                        trackInLibraryClosure?()
                        return
                    }
                    
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func fetchTracks(success: @escaping(([PulseTrack]) -> ()), failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: PulseApi.fetchTracks, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let results = response.data?.map(to: PulseResults<PulseTrack>.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success(results.results)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func removeTrack(_ track: TrackModel, success: ((PulseSuccess) -> ())? = nil, failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: PulseApi.removeTrack(track), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let result = response.data?.map(to: PulseSuccess.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success?(result)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
}

extension PulseProvider {
    fileprivate func parseError(response: Failure, closure: PulseDefaultErrorClosure?) {
        response.sendLog()
        if let error = response.error {
            closure?(PulseError(errorDescription: error.localizedDescription))
        } else if let error = response.data?.map(to: PulseError.self) {
            closure?(error)
        } else {
            closure?(nil)
        }
    }
}
