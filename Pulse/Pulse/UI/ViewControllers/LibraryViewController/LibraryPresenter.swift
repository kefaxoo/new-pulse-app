//
//  LibraryPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

protocol LibraryPresenterDelegate: AnyObject {
    func reloadData()
    func setupNavigationTitle(_ title: String)
}

final class LibraryPresenter: BasePresenter {
    private var libraryTypes: [LibraryType]
    private var service: ServiceType
    private let libraryControllerType: LibraryControllerType
    
    weak var delegate: LibraryPresenterDelegate?
    
    init(service: ServiceType, libraryControllerType: LibraryControllerType) {
        self.libraryTypes = LibraryType.allCases(by: service)
        self.service = service
        self.libraryControllerType = libraryControllerType
    }
    
    var libraryTypesCount: Int {
        return libraryTypes.count
    }
    
    func viewDidLoad() {
        self.delegate?.setupNavigationTitle(self.libraryControllerType.title)
    }
    
    func viewWillAppear() {
        self.libraryTypes = LibraryType.allCases(by: service)
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
        let libraryType = libraryTypes[indexPath.item]
        let controllerType = libraryType.controllerType(service: self.service)
        switch libraryType {
            case .tracks:
                MainCoordinator.shared.pushTracksViewController(type: controllerType)
            case .soundcloud:
                MainCoordinator.shared.pushLibraryController(type: controllerType, service: libraryType.service)
        }
    }
}
