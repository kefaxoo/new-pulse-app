//
//  VideoPlayerDelegate.swift
//
//
//  Created by Bahdan Piatrouski on 1.01.24.
//

import Foundation
import AVFoundation

public protocol VideoPlayerDelegate: AnyObject {
    func setupLayer(_ layer: AVPlayerLayer?)
}
