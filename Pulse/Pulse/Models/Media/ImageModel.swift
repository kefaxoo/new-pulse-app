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
}
