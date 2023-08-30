//
//  CoversProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import Foundation

protocol CoversProviderDelegate: AnyObject {
    func setupCovers(covers: [PulseCover])
}

class CoversProvider<V: CoversViewController>: BaseProvider {
    var covers = [PulseCover]()
    
    weak var delegate: V?
    
    func viewDidLoad() {
        guard covers.count != 30 else {
            self.delegate?.setupCovers(covers: covers)
            return
        }
        
        PulseProvider.shared.getTopCovers { [weak self] covers in
            self?.covers = covers
            self?.delegate?.setupCovers(covers: covers)
        }
    }
}
