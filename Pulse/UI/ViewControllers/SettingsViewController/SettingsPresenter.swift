//
//  SettingsPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

protocol SettingsPresenterDelegate: AnyObject {
    func reloadData()
}

final class SettingsPresenter: BasePresenter {
    private let sections = SettingSectionType.allCases
    private var closure  : (() -> ())
    
    weak var delegate: SettingsPresenterDelegate?
    
    
    init(closure: @escaping(() -> ())) {
        self.closure = closure
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].settings.count
    }
    
    func headerTitle(in section: Int) -> String {
        return sections[section].title
    }
    
    func signOut() {
        _ = SettingsManager.shared.signOut()
        _ = LibraryManager.shared.cleanLibrary()
        
        MainCoordinator.shared.makeAuthViewControllerAsRoot()
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension SettingsPresenter: BaseTableViewPresenter {
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
                    setting.setState(newState)
                })
            case .text:
                (cell as? TextTableViewCell)?.setupCell(type: setting)
            case .chevronText:
                (cell as? ChevronTableViewCell)?.setupCell(type: setting)
            case .tintedButton:
                (cell as? ButtonTableViewCell)?.setupCell(type: setting)
                (cell as? ButtonTableViewCell)?.delegate = self
            case .service:
                (cell as? ServiceSignTableViewCell)?.setupCell(type: setting)
                (cell as? ServiceSignTableViewCell)?.delegate = self
            default:
                break
        }
        
        return cell
    }
}

extension SettingsPresenter: TableViewCellDelegate {
    func reloadData() {
        self.closure()
        self.delegate?.reloadData()
    }
}
