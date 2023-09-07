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
        tableView.register(SwitchTableViewCell.self, TextTableViewCell.self, ChevronTableViewCell.self, VKAuthTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private var closure: (() -> ())
    private var sections = SettingSectionType.allCases
    
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
        guard SettingsManager.shared.signOut() else { return }
        
        MainCoordinator.shared.makeAuthViewControllerAsRoot()
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = self.sections[indexPath.section].settings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.id, for: indexPath)
        switch setting.cellType {
            case .switch:
                guard let switchCell = cell as? SwitchTableViewCell else { return cell }
                
                switchCell.setupCell(type: setting) { newState in
                    setting.setState(newState)
                }
                
                return switchCell
            case .text:
                (cell as? TextTableViewCell)?.setupCell(type: setting)
                return cell
            case .chevronText:
                (cell as? ChevronTableViewCell)?.setupCell(type: setting)
                return cell
        }
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
