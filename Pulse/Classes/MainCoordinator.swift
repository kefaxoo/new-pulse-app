//
//  MainCoordinator.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import PulseUIComponents

final class MainCoordinator: NSObject {
    static let shared = MainCoordinator()
    
    var window: UIWindow?
    
    private(set) var mainTabBarController: MainTabBarController {
        didSet {
            self.mainTabBarController.delegate = self
        }
    }
    
    var safeAreaInsets: UIEdgeInsets {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets ?? UIEdgeInsets(all: 0)
    }
    
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
    
    var currentBaseViewController: BaseUIViewController? {
        if let navigationController = self.currentViewController as? UINavigationController {
            return navigationController.viewControllers.last as? BaseUIViewController
        }
        
        return self.currentViewController as? BaseUIViewController
    }
    
    var isDarkMode: Bool {
        return self.mainTabBarController.traitCollection.userInterfaceStyle == .dark
    }
    
    override fileprivate init() {
        self.mainTabBarController = MainTabBarController()
        super.init()
    }
    
    func firstLaunch(completion: @escaping(() -> ())) {
        if SettingsManager.shared.pulse.isSignedIn {
            if NetworkManager.shared.isReachable {
                if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSign?.prod ?? false {
                    guard SettingsManager.shared.pulse.shouldUpdateToken else {
                        self.makeTabBarAsRoot()
                        completion()
                        return
                    }
                    
                    PulseProvider.shared.accessTokenV3 { [weak self] tokens in
                        SettingsManager.shared.pulse.updateTokens(tokens.tokens)
                        completion()
                        self?.makeTabBarAsRoot()
                    } failure: { [weak self] serverError, internalError in
                        self?.makeAuthViewControllerAsRoot()
                        completion()
                        let localizedError = LocalizationManager.shared.localizeError(
                            server: serverError,
                            internal: internalError,
                            default: Localization.Lines.unknownError.localization(with: "Pulse")
                        )
                        
                        guard !SettingsManager.shared.pulse.username.isEmpty else {
                            AlertView.shared.presentError(error: localizedError, system: .iOS16AppleMusic)
                            return
                        }
                        
                        self?.pushSignInViewController()
                        AlertView.shared.presentError(error: localizedError, system: .iOS16AppleMusic)
                    }
                } else {
                    PulseProvider.shared.accessToken { [weak self] loginUser in
                        SettingsManager.shared.pulse.expireAt = loginUser.expireAt ?? 0
                        SettingsManager.shared.pulse.updateAccessToken(loginUser.accessToken)
                        LibraryManager.shared.fetchLibrary()
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
    
    private func makeRootVC(vc: UIViewController, shouldUseTransition: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            self?.window?.overrideUserInterfaceStyle = SettingsManager.shared.appearance.userIntefaceStyle
            if shouldUseTransition {
                self?.window?.setRootVC(vc, options: UIWindow.TransitionOptions(direction: .fade, style: .easeInOut))
            } else {
                self?.window?.rootViewController = vc
                self?.window?.makeKeyAndVisible()
            }
        }
    }
    
    private func pushViewController(vc: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            (self?.currentViewController as? UINavigationController)?.pushViewController(vc, animated: animated)
        }
    }
    
    func makeAuthViewControllerAsRoot() {
        let authVC = AuthViewController()
        authVC.screenIdUrl = URL(string: "auth")
        self.makeRootVC(vc: authVC.configureNavigationController(preferesLargeTitles: false))
    }
    
    func pushSignUpViewController(covers: [PulseCover]) {
        let signUpVC = SignUpViewController(covers: covers)
        signUpVC.screenIdUrl = self.currentBaseViewController?.screenIdUrl?.appendingPathComponent("signUp")
        self.pushViewController(vc: signUpVC)
    }
    
    func pushSignInViewController(covers: [PulseCover] = []) {
        let signInVC = SignInViewController(covers: covers)
        signInVC.screenIdUrl = self.currentBaseViewController?.screenIdUrl?.appendingPathComponent("signIn")
        self.pushViewController(vc: signInVC)
    }
    
    func makeTabBarAsRoot() {
        self.mainTabBarController = MainTabBarController()
        LibraryManager.shared.fetchLibrary()
        self.makeRootVC(vc: self.mainTabBarController)
    }
    
    func makeBlockScreenAsRoot() {
        self.makeRootVC(vc: AccountBlockedViewController(), shouldUseTransition: true)
    }
    
    func present(_ vc: UIViewController, animated: Bool = true) {
        self.currentViewController?.present(vc, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        DispatchQueue.main.async {
            (self.currentViewController as? UINavigationController)?.popViewController(animated: animated)
        }
    }
    
    func pushTracksViewController(type: LibraryControllerType = .none, scheme: PulseWidgetsScheme = .none) {
        let tracksVC = TracksViewController(type: type, scheme: scheme)
        self.pushViewController(vc: tracksVC)
    }
    
    func presentNowPlayingController() {
        guard AudioPlayer.shared.track != nil else { return }
        
        let nowPlayingVC = NowPlayingViewController()
        self.mainTabBarController.present(nowPlayingVC, animated: true)
    }
    
    func presentStoryTrackController(track: TrackModel, story: PulseStory, completion: (() -> ())?) {
        self.mainTabBarController.present(StoryTrackViewController(track: track, story: story, completion: completion), animated: true)
    }
    
    func presentWebController(type: WebViewType = .none, delegate: WebViewControllerDelegate? = nil) {
        guard type != .none else { return }
        
        let webVC = WebViewController(type: type)
        webVC.delegate = delegate
        self.present(webVC)
    }
    
    func pushLibraryController(type: LibraryControllerType = .none, service: ServiceType = .none) {
        let libraryVC = LibraryViewController(type: type, service: service)
        self.pushViewController(vc: libraryVC)
    }
    
    func pushPlaylistsViewController(type: LibraryControllerType) {
        let playlistsVC = PlaylistsViewController(type: type)
        self.pushViewController(vc: playlistsVC)
    }
    
    func pushPlaylistViewController(type: LibraryControllerType, playlist: PlaylistModel) {
        let playlistVC = PlaylistViewController(type: type, playlist: playlist)
        self.pushViewController(vc: playlistVC)
    }
    
    func makeLaunchScreenAsRoot() {
        guard let launchScreenVC = UIStoryboard.launchScreen.viewController else { return }
        
        self.makeRootVC(vc: launchScreenVC, shouldUseTransition: false)
    }
    
    func pushArtistViewController(artist: ArtistModel) {
        self.pushViewController(vc: ArtistViewController(artist: artist))
    }
    
    func presentOpenInServiceViewController(track: TrackModel) {
        self.present(OpenInServiceViewController(track: track), animated: true)
    }
}

// MARK: -
// MARK: UITabBarControllerDelegate
extension MainCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController),
              index < 2
        else { return }
        
        SettingsManager.shared.lastTabBarIndex = index
    }
}
