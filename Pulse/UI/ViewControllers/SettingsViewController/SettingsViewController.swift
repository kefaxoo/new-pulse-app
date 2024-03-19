//
//  SettingsViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit
import PulseUIComponents

protocol SettingsView: AnyObject {
    func reloadData()
    func reloadCells(at indexPaths: [IndexPath])
    func reloadCells(at section: Int)
}

class SettingsViewController: BaseUIViewController {
    private lazy var settingsTableView: BaseUITableView = {
        let tableView = BaseUITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.register(
            SwitchTableViewCell.self,
            TextTableViewCell.self,
            ChevronTableViewCell.self,
            ServiceSignTableViewCell.self,
            ButtonTableViewCell.self
        )
        
        tableView.delegate = self
        tableView.footerHeight = NowPlayingView.height
        return tableView
    }()
    
    private let presenter: SettingsPresenterProtocol
    
    init(closure: @escaping(() -> ())) {
        self.presenter = SettingsPresenter(closure: closure)
        
        super.init(nibName: nil, bundle: nil)
        self.presenter.setView(self)
        self.screenIdUrl = URL(string: "settings")
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Localization.Words.signOut.localization,
            style: .plain,
            target: self,
            action: #selector(signOutAction)
        )
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
        return self.presenter.headerTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -
// MARK: SettingsPresenterDelegate
extension SettingsViewController: SettingsView {
    func reloadData() {
        self.settingsTableView.reloadData()
    }
    
    func reloadCells(at indexPaths: [IndexPath]) {
        self.settingsTableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func reloadCells(at section: Int) {
        self.settingsTableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}
