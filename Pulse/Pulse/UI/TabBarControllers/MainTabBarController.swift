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
        setupLayout()
        setupConstraints()
        setupItems()
    }
    
    private func setupLayout() {
        self.tabBar.addSubview(nowPlayingView)
    }
    
    private func setupConstraints() {
        nowPlayingView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.bottom.equalTo(self.tabBar.snp.top)
        }
    }
    
    private func setupItems() {
        let settingsVC = SettingsViewController { [weak self] in
            self?.nowPlayingView.tintColor = SettingsManager.shared.color.color
            self?.tabBar.tintColor = SettingsManager.shared.color.color
        }
        
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: Constants.Images.System.gear), tag: 1000)
        self.tabBar.tintColor = SettingsManager.shared.color.color
        self.viewControllers = [
            settingsVC.configureNavigationController(title: "Settings")
        ]
        
        guard let firstNavigationController = self.viewControllers?.first(where: { $0 as? UINavigationController != nil }) else { return }
        
        MainCoordinator.shared.currentNavigationController = firstNavigationController as? UINavigationController
    }
}
