//
//  SettingsPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit
import PulseUIComponents

protocol SettingsPresenterProtocol: AnyObject, BasePresenter, BaseTableViewPresenter {
    var numberOfSections: Int { get }
    
    func setView(_ view: SettingsView?)
    func numberOfRows(in section: Int) -> Int
    func headerTitle(for section: Int) -> String?
    func signOut()
}

final class SettingsPresenter: SettingsPresenterProtocol {
    private let sections = SettingSectionType.allCases
    private var closure  : (() -> ())
    
    weak var view: SettingsView?
    
    init(closure: @escaping(() -> ())) {
        self.closure = closure
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .reloadSettings, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .reloadSettings, object: nil)
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    func setView(_ view: SettingsView?) {
        self.view = view
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].settings.count
    }
    
    func headerTitle(for section: Int) -> String? {
        return sections[section].title
    }
    
    func signOut() {
        LogoutPopUpViewController().present()
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension SettingsPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(
            tableView.dequeueReusableCell(
                withIdentifier: self.sections[indexPath.section].settings[indexPath.row].id,
                for: indexPath
            ),
            at: indexPath
        )
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        let setting = self.sections[indexPath.section].settings[indexPath.row]
        switch setting.cellType {
            case .switch:
                (cell as? SwitchTableViewCell)?.setupCell(type: setting, closure: { newState in
                    PulseProvider.shared.updateSettings()
                    setting.setState(newState)
                })
            case .text:
                (cell as? TextTableViewCell)?.setupCell(type: setting)
            case .chevronText:
                (cell as? ChevronTableViewCell)?.setupCell(type: setting)
            case .tintedButton:
                (cell as? ButtonTableViewCell)?.setupCell(type: setting, indexPath: indexPath)
                (cell as? ButtonTableViewCell)?.delegate = self
            case .service:
                (cell as? ServiceSignTableViewCell)?.setupCell(type: setting, section: indexPath.section)
                (cell as? ServiceSignTableViewCell)?.delegate = self
            default:
                break
        }
        
        return cell
    }
}

extension SettingsPresenter: TableViewCellDelegate {
    @objc func reloadData() {
        self.closure()
        self.view?.reloadData()
    }
    
    func reloadCells(at indexPaths: [IndexPath]) {
        self.view?.reloadCells(at: indexPaths)
    }
    
    func reloadCells(at section: Int) {
        self.view?.reloadCells(at: section)
    }
}
