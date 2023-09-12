//
//  LibraryViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

final class LibraryViewController: BaseUIViewController {
    private lazy var libraryTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(LibraryTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var presenter: LibraryPresenter = {
        let presenter = LibraryPresenter()
        return presenter
    }()
}

// MARK: -
// MARK: Setup interface methods
extension LibraryViewController {
    override func setupLayout() {
        self.view.addSubview(libraryTableView)
    }
    
    override func setupConstraints() {
        libraryTableView.snp.makeConstraints { make in
            make.height.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension LibraryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.libraryTypesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(tableView: tableView, for: indexPath)
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension LibraryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter.didSelectRow(at: indexPath)
    }
}
