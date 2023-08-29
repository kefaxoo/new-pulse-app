//
//  AuthProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

protocol AuthProviderDelegate: AnyObject {
    func setupCovers(covers: [PulseCover])
}

final class AuthProvider: BaseProtocol {
    private var covers = [PulseCover]()
    
    weak var delegate: AuthProviderDelegate?
    private var view: AuthViewController? {
        return delegate as? AuthViewController
    }
    
    func viewDidLoad() {
        PulseProvider.shared.getTopCovers { [weak self] covers in
            self?.covers = covers
            self?.delegate?.setupCovers(covers: covers)
        }
    }
}
