//
//  LibraryPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

protocol LibraryPresenterDelegate: AnyObject {
    func reloadData()
}

final class LibraryPresenter: BasePresenter {
    private var libraryTypes = LibraryType.allCases
    
    weak var delegate: LibraryPresenterDelegate?
    
    var libraryTypesCount: Int {
        return libraryTypes.count
    }
    
    func viewWillAppear() {
        self.libraryTypes = LibraryType.allCases
        self.delegate?.reloadData()
    }
    
    func setupCell(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: LibraryTableViewCell.id, for: indexPath), for: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        (cell as? LibraryTableViewCell)?.setupCell(self.libraryTypes[indexPath.item])
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        MainCoordinator.shared.pushTracksViewController(type: libraryTypes[indexPath.item].controllerType)
    }
}
