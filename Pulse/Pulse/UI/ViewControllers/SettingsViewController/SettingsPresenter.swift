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
    
    func cellIdFor(indexPath: IndexPath) -> String {
        return sections[indexPath.section].settings[indexPath.row].id
    }
    
    func setupCell(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
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
            case .colorButton:
                (cell as? ColorSettingTableViewCell)?.setupCell(type: setting)
                (cell as? ColorSettingTableViewCell)?.delegate = self
            case .service:
                (cell as? ServiceSignTableViewCell)?.setupCell(type: setting)
                (cell as? ServiceSignTableViewCell)?.delegate = self
            default:
                break
        }
        
        return cell
    }
    
    func signOut() {
        guard SettingsManager.shared.signOut(),
              LibraryManager.shared.cleanLibrary()
        else { return }
        
        MainCoordinator.shared.makeAuthViewControllerAsRoot()
    }
}

extension SettingsPresenter: TableViewCellDelegate {
    func reloadData() {
        self.closure()
        self.delegate?.reloadData()
    }
}
