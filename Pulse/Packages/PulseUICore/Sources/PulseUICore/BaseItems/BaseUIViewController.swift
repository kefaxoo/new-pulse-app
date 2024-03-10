//
//  BaseUIViewController.swift
//
//
//  Created by Bahdan Piatrouski on 8.03.24.
//

import UIKit

open class BaseUIViewController: UIViewController {
    open override func viewDidLoad() {
        self.viewDidLoad()
        self.setupInterface()
    }
}

// MARK: -
// MARK: Setup interface methods
extension BaseUIViewController {
    @objc open func setupInterface() {
        #if os(iOS)
        self.view.backgroundColor = .systemBackground
        #endif
        
        self.setupLayout()
        self.setupConstraints()
    }
    
    @objc func setupLayout() {}
    @objc func setupConstraints() {}
}
