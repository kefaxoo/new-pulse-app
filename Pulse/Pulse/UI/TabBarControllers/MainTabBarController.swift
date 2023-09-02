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
            guard let result = member.hitTest(subpoint, with: event) else { return nil }
            
            return result
        }
        
        return nil
    }
}

final class MainTabBarController: UITabBarController {
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
    }
    
    private func setupLayout() {
        
    }
    
    private func setupConstraints() {
        
    }
}
