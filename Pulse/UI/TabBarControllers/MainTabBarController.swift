//
//  MainTabBarController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit

fileprivate final class NowPlayingTabBar: UITabBar {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds,
              !isHidden,
              alpha > 0
        else { return nil }
        
        for member in subviews.reversed() {
            let subpoint = member.convert(point, from: self)
            guard let result = member.hitTest(subpoint, with: event) else { continue }
            
            return result
        }
        
        return nil
    }
}

final class MainTabBarController: UITabBarController {
    private lazy var nowPlayingView = NowPlayingView()
    private lazy var blurBackgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, NowPlayingTabBar.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTabBar()
    }
    
    private func configureTabBar() {
        self.tabBar.backgroundColor = .clear
        
        setupLayout()
        setupConstraints()
        setupItems()
    }
    
    private func setupLayout() {
        self.tabBar.addSubview(blurBackgroundView)
        self.tabBar.addSubview(nowPlayingView)
    }
    
    private func setupConstraints() {
        nowPlayingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.tabBar.snp.top)
            make.height.equalTo(NowPlayingView.height)
        }
        
        blurBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(nowPlayingView.snp.top)
        }
    }
    
    private func setupItems() {
        let settingsVC = SettingsViewController { [weak self] in
            self?.nowPlayingView.tintColor = SettingsManager.shared.color.color
            self?.tabBar.tintColor = SettingsManager.shared.color.color
        }
        
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: Constants.Images.settings.image, tag: 1000)
        
        let searchVC = SearchViewController(nibName: nil, bundle: nil)
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: Constants.Images.search.image, tag: 1001)
        
        let libraryVC = LibraryViewController(type: .library, service: .none)
        libraryVC.tabBarItem = UITabBarItem(
            title: "Library",
            image: Constants.Images.libraryNonSelected.image,
            selectedImage: Constants.Images.librarySelected.image
        )
        
        self.tabBar.tintColor = SettingsManager.shared.color.color
        self.viewControllers = [
            libraryVC.configureNavigationController(title: "Library"),
            searchVC.configureNavigationController(title: "Search"),
            settingsVC.configureNavigationController(title: "Settings")
        ]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurBackgroundView.effect = UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
}
