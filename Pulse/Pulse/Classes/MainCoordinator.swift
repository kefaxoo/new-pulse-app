//
//  MainCoordinator.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

final class MainCoordinator {
    static let shared = MainCoordinator()
    
    var window: UIWindow?
    
    fileprivate init() {}
    
    func firstLaunch() {
        if let pulseAccessToken = SettingsManager.shared.pulse.accessToken,
           !pulseAccessToken.isEmpty {
            
        } else {
            let authVC = AuthViewController(nibName: nil, bundle: nil)
            self.makeRootVC(vc: authVC)
        }
    }
    
    private func makeRootVC(vc: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController = vc
            self?.window?.makeKeyAndVisible()
        }
    }
}
