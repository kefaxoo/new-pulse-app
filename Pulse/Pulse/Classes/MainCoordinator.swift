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
    
    private(set) var mainTabBarController: MainTabBarController
    
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
    
    fileprivate init() {
        self.mainTabBarController = MainTabBarController()
    }
    
    func firstLaunch(completion: @escaping(() -> ())) {
        if let pulseAccessToken = SettingsManager.shared.pulse.accessToken,
           !pulseAccessToken.isEmpty {
            if NetworkManager.shared.isReachable {
                let emptyVC = UIViewController.empty
                self.makeRootVC(vc: emptyVC)
                emptyVC.presentSpinner()
                PulseProvider.shared.accessToken { [weak self] loginUser in
                    SettingsManager.shared.pulse.expireAt = loginUser.expireAt ?? 0
                    SettingsManager.shared.pulse.updateAccessToken(loginUser.accessToken)
                    LibraryManager.shared.fetchLibrary()
                    emptyVC.dismissSpinner()
                    completion()
                    self?.makeTabBarAsRoot()
                } failure: { [weak self] error in
                    self?.makeAuthViewControllerAsRoot()
                    completion()
                    guard !SettingsManager.shared.pulse.username.isEmpty else {
                        AlertView.shared.presentError(error: error?.errorDescription, system: .iOS16AppleMusic)
                        return
                    }
                    
                    self?.pushSignInViewController()
                    AlertView.shared.presentError(error: error?.errorDescription, system: .iOS16AppleMusic)
                }
            } else {
                completion()
                self.makeTabBarAsRoot()
            }
        } else {
            self.makeAuthViewControllerAsRoot()
            completion()
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
        self.mainTabBarController = MainTabBarController()
        LibraryManager.shared.fetchLibrary()
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
    
    func presentNowPlayingController() {
        guard AudioPlayer.shared.track != nil else { return }
        
        let nowPlayingVC = NowPlayingViewController()
        self.present(nowPlayingVC)
    }
}
