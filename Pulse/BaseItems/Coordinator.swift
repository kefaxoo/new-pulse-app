//
//  Coordinator.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.03.24.
//

import UIKit

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator?] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

extension Coordinator {
    func start() {}
}
