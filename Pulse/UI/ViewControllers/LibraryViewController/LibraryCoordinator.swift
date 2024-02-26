//
//  LibraryCoordinator.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 26.02.24.
//

import UIKit

class LibraryCoordinator: Coordinator {
    var navigationController: UINavigationController?
}

extension LibraryCoordinator {
    func pushTracksViewController(withType type: LibraryControllerType) {
        let tracksVC = TracksViewController(type: type, scheme: .none)
        self.push(tracksVC)
    }
    
    func pushLibraryViewController(withType type: LibraryControllerType, service: ServiceType) {
        let coordinator = LibraryCoordinator()
        coordinator.navigationController = self.navigationController
        
        let libraryVC = LibraryViewController(type: type, service: service, coordinator: coordinator)
        self.push(libraryVC)
    }
}
