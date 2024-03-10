//
//  Protocol.swift
//
//
//  Created by Bahdan Piatrouski on 8.03.24.
//

import UIKit

public protocol Coordinator {
    var navigationController: UINavigationController { get set }
    
    func start()
}
