//
//  LibraryPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

protocol LibraryPresenterProtocol: BasePresenter, BaseTableViewPresenter {
    var libraryTypesCount: Int { get }
    
    func setView(_ view: LibraryView?)
}

final class LibraryPresenter: LibraryPresenterProtocol {
    private var libraryTypes: [LibraryType]
    private var service: ServiceType
    private let libraryControllerType: LibraryControllerType
    private let coordinator: LibraryCoordinator
    
    weak var view: LibraryView?
    
    init(service: ServiceType, libraryControllerType: LibraryControllerType, coordinator: LibraryCoordinator) {
        self.libraryTypes = LibraryType.allCases(by: service)
        self.service = service
        self.libraryControllerType = libraryControllerType
        self.coordinator = coordinator
    }
    
    var libraryTypesCount: Int {
        return libraryTypes.count
    }
    
    func viewDidLoad() {
        self.view?.setupNavigationTitle(self.libraryControllerType.title)
    }
    
    func viewWillAppear() {
        self.libraryTypes = LibraryType.allCases(by: service)
        self.view?.reloadData()
    }
    
    func setView(_ view: LibraryView?) {
        self.view = view
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension LibraryPresenter: BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: LibraryTableViewCell.id, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        (cell as? LibraryTableViewCell)?.setupCell(self.libraryTypes[indexPath.item])
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let libraryType = libraryTypes[indexPath.item]
        let controllerType = libraryType.controllerType(service: self.service)
        switch libraryType {
            case .playlists:
                MainCoordinator.shared.pushPlaylistsViewController(type: controllerType)
            case .tracks:
                self.coordinator.pushTracksViewController(withType: controllerType)
            case .soundcloud, .yandexMusic:
                self.coordinator.pushLibraryViewController(withType: controllerType, service: libraryType.service)
        }
    }
}
