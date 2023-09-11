//
//  ImageModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

final class ImageModel {
    let small   : String
    let original: String
    
    init(_ image: MuffonImage?) {
        self.small    = image?.small ?? ""
        self.original = image?.original ?? ""
    }
    
    init?(coverFilename: String) {
        guard !coverFilename.isEmpty,
              let url = URL(filename: coverFilename, path: .documentDirectory)
        else { return nil }
        
        self.small = url.absoluteString
        self.original = url.absoluteString
    }
    
    func contains(_ link: String) -> Bool {
        return small.contains(link) ? true : original.contains(link)
    }
}
