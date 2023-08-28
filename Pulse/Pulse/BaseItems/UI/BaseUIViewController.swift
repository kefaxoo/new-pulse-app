//
//  BaseUIViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

class BaseUIViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
}

extension BaseUIViewController {
    @objc func setupInterface() {
        self.view.backgroundColor = UIColor.systemBackground
        setupLayout()
        setupConstraints()
    }
    
    @objc func setupLayout() {}
    @objc func setupConstraints() {}
}
