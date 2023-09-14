//
//  NowPlayingPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.09.23.
//

import UIKit

protocol NowPlayingPresenterDelegate: AnyObject {
    func setCover(_ cover: UIImage?)
}

final class NowPlayingPresenter: BasePresenter {
    weak var delegate: NowPlayingPresenterDelegate?
    
    init() {}
    
    func viewDidLoad() {
        if let cover = AudioPlayer.shared.cover {
            self.delegate?.setCover(cover)
        }
    }
}
