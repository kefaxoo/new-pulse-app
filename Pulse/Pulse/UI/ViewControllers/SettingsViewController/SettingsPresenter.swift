//
//  SettingsPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

final class SettingsPresenter: BasePresenter {
    private let sections = SettingSectionType.allCases
    
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
        }
        
        return cell
    }
}
