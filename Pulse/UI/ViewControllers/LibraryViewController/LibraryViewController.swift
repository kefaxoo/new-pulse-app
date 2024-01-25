//
//  LibraryViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit
import PulseUIComponents

final class LibraryViewController: BaseUIViewController {
    private lazy var libraryTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(LibraryTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private let presenter: LibraryPresenter
    
    init(type: LibraryControllerType = .none, service: ServiceType = .none) {
        self.presenter = LibraryPresenter(service: service, libraryControllerType: type)
        super.init(nibName: nil, bundle: nil)
        self.presenter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Lifecycle
extension LibraryViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
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
    
    func applyColor() {
        self.libraryTableView.visibleCells.forEach({ ($0 as? LibraryTableViewCell)?.changeColor() })
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension LibraryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.libraryTypesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.presenter.setupCell(for: tableView, at: indexPath)
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

// MARK: -
// MARK: LibraryPresenterDelegate
extension LibraryViewController: LibraryPresenterDelegate {
    func reloadData() {
        self.libraryTableView.reloadData()
    }
    
    func setupNavigationTitle(_ title: String) {
        self.navigationItem.title = title
    }
}
