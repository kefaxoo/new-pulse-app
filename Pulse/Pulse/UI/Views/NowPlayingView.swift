//
//  NowPlayingView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit

final class NowPlayingView: UIView {
    private lazy var contentView: UIView = {
        let view = UIView(with: .clear)
        return view
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
}
