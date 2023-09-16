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
        tableView.dataSource = self
        tableView.register(SwitchTableViewCell.self, TextTableViewCell.self, ChevronTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private var closure: (() -> ())
    private lazy var presenter: SettingsPresenter = {
        let presenter = SettingsPresenter()
        return presenter
    }()
    
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
    override func setupInterface() {
        super.setupInterface()
        self.setupNavigationController()
    }
    
    override func setupLayout() {
        self.view.addSubview(settingsTableView)
    }
    
    override func setupConstraints() {
        settingsTableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
    private func setupNavigationController() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutAction))
    }
}

// MARK: -
// MARK: Actions
extension SettingsViewController {
    @objc private func signOutAction(_ sender: UIBarButtonItem) {
        self.presenter.signOut()
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.presenter.headerTitle(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.presenter.cellIdFor(indexPath: indexPath), for: indexPath)
        return self.presenter.setupCell(cell, for: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
