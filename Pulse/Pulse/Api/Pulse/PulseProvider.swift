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
        ) { response in
            switch response {
                case .success(let response):
                    guard self.checkStatusCode(response.statusCode, compareTo: 201),
                          let createUser = response.data?.map(to: PulseCreateUser.self) 
                    else {
                        failure(nil)
                        return
                    }
                    
                    success(createUser)
                case .failure(let response):
                    if let error = response.error {
                        failure(PulseError(errorDescription: error.localizedDescription))
                        return
                    } else if let error = response.data?.map(to: PulseError.self) {
                        failure(error)
                        return
                    }
                    
                    failure(nil)
                    return
            }
        }
    }
    
    func loginUser(credentials: Credentials, success: @escaping((PulseLoginUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(with: URLRequest(
            type: PulseApi.loginUser(credentials: credentials),
            decodeToHttp: true,
            shouldPrintLog: self.shouldPrintLog
        )) { response in
            switch response {
                case .success(let response):
                    guard self.checkStatusCode(response.statusCode, compareTo: 200),
                          let loginUser = response.data?.map(to: PulseLoginUser.self)
                    else { 
                        failure(nil)
                        return
                    }
                    
                    success(loginUser)
                case .failure(let response):
                    if let error = response.error {
                        failure(PulseError(errorDescription: error.localizedDescription))
                        return
                    } else if let error = response.data?.map(to: PulseError.self) {
                        failure(error)
                        return
                    }
                    
                    failure(nil)
                    return
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
                case .failure:
                    failure?()
                    return
            }
        }
    }
}
