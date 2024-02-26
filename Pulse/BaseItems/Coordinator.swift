//
//  Coordinator.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.02.24.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    
    func start()
    func present(_ vc: UIViewController, animated: Bool)
    func push(_ vc: UIViewController, animated: Bool)
}

extension Coordinator {
    func start() {}
    
    func present(_ vc: UIViewController, animated: Bool = true) {
        self.navigationController?.present(vc, animated: animated)
    }
    
    func push(_ vc: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}
