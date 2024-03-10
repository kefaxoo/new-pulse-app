//
//  PulseDeviceProvider.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation
import FriendlyURLSession

public final class PulseDeviceProvider: BaseRestApiProvider {
    public static let shared = PulseDeviceProvider()
    
    fileprivate init() {
        super.init(
            shouldPrintLog: AppEnvironment.current.isDebug,
            shouldCancelTask: false
        )
    }
    
    public func fetchInfo(completion: @escaping((_ deviceInfo: PulseDeviceInfo?) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.deviceInfo, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    completion(response.data?.map(to: PulseDeviceInfo.self))
                case .failure:
                    completion(nil)
            }
        }
    }
}
