//
//  SearchResponse.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

struct SearchResponse {
    var page: Int = 0
    var results: [Decodable]
    var canLoadMore = true
    
    mutating func addResults(_ searchResponse: SearchResponse) {
        self.page = searchResponse.page
        self.results.append(contentsOf: searchResponse.results)
        self.canLoadMore = true
    }
    
    mutating func cannotLoadMore() {
        self.canLoadMore = false
    }
}
