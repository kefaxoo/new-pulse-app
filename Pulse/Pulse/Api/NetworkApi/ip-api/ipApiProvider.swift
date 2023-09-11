//
//  ipApiProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import FriendlyURLSession

final class ipApiProvider: BaseRestApiProvider {
    static let shared = ipApiProvider()
    
    override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func getInfo(success: @escaping((IpModel) -> ()), failure: EmptyClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: ipApi.getCountry, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let ipModel = response.data?.map(to: ResponseIpApiModel.self) else {
                        failure?()
                        return
                    }
                    
                    success(ipModel)
                case .failure:
                    failure?()
            }
        }
    }
}
