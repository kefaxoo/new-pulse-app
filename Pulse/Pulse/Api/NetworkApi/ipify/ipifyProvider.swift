//
//  ipifyProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation
import FriendlyURLSession

final class ipifyProvider: BaseRestApiProvider {
    static let shared = ipifyProvider()
    
    fileprivate override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func getIp(success: @escaping((String) -> ()), failure: @escaping EmptyClosure) {
        urlSession.dataTask(with: URLRequest(type: ipifyApi.getIp, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let ip = response.data?.map(to: ResponseIpifyModel.self)?.ip else {
                        failure()
                        return
                    }
                    
                    success(ip)
                case .failure:
                    failure()
                    return
            }
        }
    }
}
