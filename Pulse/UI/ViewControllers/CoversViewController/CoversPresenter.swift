//
//  CoversPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import Foundation

protocol CoversPresenterDelegate: AnyObject {
    func setupCovers(covers: [PulseCover])
}

class CoversPresenter<V: CoversViewController>: BasePresenter {
    var covers = [PulseCover]()
    
    weak var delegate: V?
    
    func viewDidLoad() {
        guard covers.isEmpty else {
            self.delegate?.setupCovers(covers: covers)
            return
        }
        
        PulseProvider.shared.getTopCovers { [weak self] covers in
            self?.covers = covers
            self?.delegate?.setupCovers(covers: covers)
        }
    }
}
