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
    private var currentNavigationController: UINavigationController?
    
    fileprivate init() {}
    
    func firstLaunch() {
        if let pulseAccessToken = SettingsManager.shared.pulse.accessToken,
           !pulseAccessToken.isEmpty {
            
        } else {
            let authVC = AuthViewController(nibName: nil, bundle: nil).configureNavigationController(preferesLargeTitles: false)
            self.currentNavigationController = authVC
            self.makeRootVC(vc: authVC)
        }
    }
    
    private func makeRootVC(vc: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController = vc
            self?.window?.makeKeyAndVisible()
        }
    }
    
    private func pushViewController(vc: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            self?.currentNavigationController?.pushViewController(vc, animated: animated)
        }
    }
    
    func pushSignUpViewController(covers: [PulseCover]) {
        let signUpVC = SignUpViewController.initWithCovers(covers)
        self.pushViewController(vc: signUpVC)
    }
    
    func pushSignInViewController(covers: [PulseCover]) {
        
    }
}
