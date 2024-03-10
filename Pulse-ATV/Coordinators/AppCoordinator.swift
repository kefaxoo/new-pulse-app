//
//  AppCoordinator.swift
//  Pulse-ATV
//
//  Created by Bahdan Piatrouski on 8.03.24.
//

import UIKit
import PulseCore
import PulseUICore

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    let window: UIWindow
    
    init(navigationController: UINavigationController, window: UIWindow) {
        self.navigationController = navigationController
        self.window = window
    }
    
    func start() {
        let splashScreenVC = SplashScreenViewController()
        window.rootViewController = splashScreenVC
        window.makeKeyAndVisible()
    }
}
