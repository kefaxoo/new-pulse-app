//
//  ResponseSoundcloudMainModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ResponseSoundcloudMainModel<T>: Decodable where T: Decodable {
    let collection: [T]
    let nextLink: String?
    
    var cursor: String? {
        let urlComponents = URLComponents(string: self.nextLink ?? "")
        return urlComponents?.queryItems?.first(where: { $0.name == "cursor" })?.value
    }
    
    var offset: String? {
        let urlComponents = URLComponents(string: self.nextLink ?? "")
        return urlComponents?.queryItems?.first(where: { $0.name == "offset" })?.value
    }
    
    enum CodingKeys: String, CodingKey {
        case collection
        case nextLink = "next_href"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.collection = try container.decode([T].self, forKey: .collection)
        self.nextLink = try container.decodeIfPresent(String.self, forKey: .nextLink)
    }
}
