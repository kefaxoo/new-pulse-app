//
//  OdesliProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import Foundation
import FriendlyURLSession

final class OdesliProvider: BaseRestApiProvider {
    static let shared = OdesliProvider()
    
    fileprivate init() {
        super.init(shouldPrintLog: Constants.isDebug)
    }
    
    func fetchTrackLinks(for track: TrackModel, success: @escaping((OdesliRoot) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: OdesliApi.songLinks(track: track), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let root = response.data?.map(to: OdesliRoot.self) else { return }
                    
                    success(root)
                case .failure:
                    break
            }
        }
    }
}
