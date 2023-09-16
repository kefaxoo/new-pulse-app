//
//  IpifyProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation
import FriendlyURLSession

final class IpifyProvider: BaseRestApiProvider {
    static let shared = IpifyProvider()
    
    fileprivate override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func getIp(success: @escaping((String) -> ()), failure: @escaping EmptyClosure) {
        urlSession.dataTask(with: URLRequest(type: IpifyApi.getIp, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let ip = response.data?.map(to: ResponseIpifyModel.self)?.ip else {
                        failure()
                        return
                    }
                    
                    success(ip)
                case .failure(let response):
                    response.sendLog()
                    failure()
                    return
            }
        }
    }
}
