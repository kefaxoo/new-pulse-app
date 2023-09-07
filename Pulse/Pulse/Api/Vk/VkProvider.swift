//
//  VkProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import Foundation
import FriendlyURLSession

final class VkProvider: BaseRestApiProvider {
    static let shared = VkProvider()
    
    override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func login(credentials: Credentials, success: @escaping((VkAuth) -> ()), failure: @escaping((VkError?) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: VkApi.auth(credentials: credentials), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let vkAuth = response.data?.map(to: VkAuth.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(vkAuth)
                case .failure(let response):
                    guard let vkError = response.data?.map(to: VkError.self) else {
                        failure(nil)
                        return
                    }
                    
                    failure(vkError)
                    return
            }
        }
    }
}
