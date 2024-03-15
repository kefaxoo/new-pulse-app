//
//  DeezerProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.02.24.
//

import Foundation
import FriendlyURLSession

final class DeezerProvider: BaseRestApiProvider {
    static let shared = DeezerProvider()
    
    fileprivate init() {
        super.init(shouldPrintLog: Constants.isDebug)
    }
    
    func fetchArtistInfo(for artist: ArtistModel, success: @escaping((ArtistModel) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: DeezerApi.artist(artistId: artist.id), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let artist = response.data?.map(to: DeezerArtist.self) else { return }
                    
                    success(ArtistModel(artist))
                case .failure:
                    break
            }
        }
    }
}
