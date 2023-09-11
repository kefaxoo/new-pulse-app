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
    
    private lazy var mainTabBarController: MainTabBarController = {
        let mainTabBarController = MainTabBarController()
        return mainTabBarController
    }()
    
    var currentTabBarIndex: Int {
        return mainTabBarController.selectedIndex
    }
    
    var currentViewController: UIViewController? {
        guard let rootVC = window?.rootViewController else { return nil }
        
        var currentVC: UIViewController! = rootVC
        while currentVC.presentedViewController != nil {
            currentVC = currentVC.presentedViewController
        }
        
        if currentVC is MainTabBarController {
            currentVC = mainTabBarController.viewControllers?[self.currentTabBarIndex]
            while currentVC.presentedViewController != nil {
                currentVC = currentVC.presentedViewController
            }
        }
        
        return currentVC
    }
    
    fileprivate init() {}
    
    func firstLaunch() {
        if let pulseAccessToken = SettingsManager.shared.pulse.accessToken,
           !pulseAccessToken.isEmpty {
            self.makeTabBarAsRoot()
        } else {
            self.makeAuthViewControllerAsRoot()
            guard !SettingsManager.shared.pulse.username.isEmpty else { return }
            
            self.pushSignInViewController()
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
            (self?.currentViewController as? UINavigationController)?.pushViewController(vc, animated: animated)
        }
    }
    
    func makeAuthViewControllerAsRoot() {
        let authVC = AuthViewController(nibName: nil, bundle: nil).configureNavigationController(preferesLargeTitles: false)
        self.makeRootVC(vc: authVC)
    }
    
    func pushSignUpViewController(covers: [PulseCover]) {
        let signUpVC = SignUpViewController(covers: covers)
        self.pushViewController(vc: signUpVC)
    }
    
    func pushSignInViewController(covers: [PulseCover] = []) {
        let signInVC = SignInViewController(covers: covers)
        self.pushViewController(vc: signInVC)
    }
    
    func makeTabBarAsRoot() {
        self.makeRootVC(vc: self.mainTabBarController)
    }
    
    func present(_ vc: UIViewController, animated: Bool = true) {
        self.currentViewController?.present(vc, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        DispatchQueue.main.async {
            (self.currentViewController as? UINavigationController)?.popViewController(animated: animated)
        }
    }
    
    func pushTracksViewController(type: LibraryControllerType) {
        let tracksVC = TracksViewController(type: type)
        self.pushViewController(vc: tracksVC)
    }
}
