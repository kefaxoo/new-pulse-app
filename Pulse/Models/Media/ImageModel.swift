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
        
        self.small    = url.absoluteString
        self.original = url.absoluteString
    }
    
    init?(_ link: String?) {
        guard let link else { return nil }
        
        self.small    = link
        self.original = link
    }
    
    init(_ cover: PulseCover) {
        self.small = cover.medium
        self.original = cover.xl
    }
    
    init(small: String, original: String) {
        self.small = small
        self.original = original
    }
    
    var isSmallEqualToOriginal: Bool {
        return self.small == self.original
    }
    
    var isImageLocal: Bool {
        return !(self.small.contains("http") || self.original.contains("http"))
    }
    
    func contains(_ link: String) -> Bool {
        return small.contains(link) ? true : original.contains(link)
    }
}
