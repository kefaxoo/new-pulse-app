//
//  SearchCoordinator.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.03.24.
//

import UIKit

final class SearchCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    
    var children: [Coordinator?]
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.navigationBar.tintColor = SettingsManager.shared.color.color
        self.navigationController.tabBarItem = UITabBarItem(
            title: Localization.Words.search.localization,
            image: Constants.Images.search.image,
            tag: 1001
        )
        
        self.children = []
    }
    
    func start() {
        let searchViewController = NewSearchViewController(viewModel: SearchViewModel(coordinator: self))
        searchViewController.navigationItem.title = Localization.Words.search.localization
        self.navigationController.setViewControllers([searchViewController], animated: false)
    }
    
    func pushPlaylistViewController(type: LibraryControllerType, playlist: PlaylistModel) {
        self.navigationController.pushViewController(PlaylistViewController(type: type, playlist: playlist), animated: true)
    }
}
