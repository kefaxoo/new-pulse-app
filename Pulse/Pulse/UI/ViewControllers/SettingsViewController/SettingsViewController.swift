//
//  SettingsViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit

class SettingsViewController: BaseUIViewController {

    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private var closure: (() -> ())
    
    init(closure: @escaping(() -> ())) {
        self.closure = closure
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension SettingsViewController {
    override func setupLayout() {
        self.view.addSubview(settingsTableView)
    }
    
    override func setupConstraints() {
        settingsTableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}
