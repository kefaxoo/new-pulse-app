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
    
    func getCountryCode(success: @escaping((String) -> ()), failure: EmptyClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: ipApi.getCountry, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let countryCode = response.data?.map(to: ResponseIpApiModel.self)?.countryCode else {
                        failure?()
                        return
                    }
                    
                    success(countryCode)
                case .failure:
                    failure?()
            }
        }
    }
}
