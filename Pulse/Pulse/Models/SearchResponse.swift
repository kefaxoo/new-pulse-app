//
//  SearchResponse.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

struct SearchResponse {
    let page: Int
    let totalPages: Int
    var results: [Decodable]
}
