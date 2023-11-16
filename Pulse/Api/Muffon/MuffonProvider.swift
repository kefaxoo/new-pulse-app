//
//  MuffonProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation
import FriendlyURLSession

final class MuffonProvider: BaseRestApiProvider {
    static let shared = MuffonProvider(shouldCancelTask: true)
    
    fileprivate override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
    func search(
        query: String,
        in service: ServiceType,
        type: SearchType,
        page: Int = 1,
        success: @escaping((SearchResponse) -> ()),
        failure: @escaping(() -> ())
    ) {
        if self.shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(
                type: MuffonApi.search(
                    type: type,
                    service: service,
                    query: query,
                    page: page
                ),
                shouldPrintLog: self.shouldPrintLog
            ), response: { response in
                switch response {
                    case .success(let response):
                        guard let response = response.data?.map(to: MuffonSearch.self) else {
                            failure()
                            return
                        }
                        
                        success(response.searchResponse)
                    case .failure(let response):
                        guard response.statusCode != -1 else { return }
                        
                        failure()
                }
            }
        )
    }
    
    func trackInfo(_ track: TrackModel, shouldCancelTask: Bool = true, success: @escaping((MuffonTrack) -> ()), failure: @escaping(() -> ())) {
        if shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(
                type: MuffonApi.trackInfo(track),
                shouldPrintLog: self.shouldPrintLog
            ),
            response: { response in
                switch response {
                    case .success(let response):
                        guard let track = response.data?.map(to: MuffonTrackInfo.self) else {
                            failure()
                            return
                        }
                        
                        success(track.trackInfo)
                    case .failure(let response):
                        response.sendLog()
                        guard response.statusCode != -1 else { return }
                        
                        failure()
                }
            }
        )
    }
    
    func trackInfo(
        id: Int,
        service: ServiceType,
        shouldCancelTask: Bool = true,
        success: @escaping((MuffonTrack) -> ()),
        failure: (() -> ())? = nil
    ) {
        if shouldCancelTask {
            task?.cancel()
        }
        
        task = urlSession.returnDataTask(
            with: URLRequest(
                type: MuffonApi.trackInfoById(id, service: service),
                shouldPrintLog: self.shouldPrintLog
            ),
            response: { response in
                switch response {
                    case .success(let response):
                        guard let track = response.data?.map(to: MuffonTrackInfo.self) else {
                            failure?()
                            return
                        }
                        
                        success(track.trackInfo)
                    case .failure(let response):
                        response.sendLog()
                        guard response.statusCode != -1 else { return }
                        
                        failure?()
                }
            }
        )
    }
}
