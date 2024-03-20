//
//  OpenInServiceViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import UIKit
import PulseUIComponents

protocol OpenInServiceViewProtocol: AnyObject {
    func reloadData()
}

final class OpenInServiceViewController: BaseUIViewController {
    private lazy var trackInfoTableHeaderView: OpenInServiceView = {
        return OpenInServiceView().configure(track: self.track)
    }()
    
    private lazy var servicesTableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.tableHeaderView = trackInfoTableHeaderView
        tableView.register(ServiceTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var presenter: OpenInServiceProtocol = {
        return OpenInServicePresenter(track: self.track, view: self)
    }()
    
    private let track: TrackModel
    
    init(track: TrackModel) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Lifecycle
extension OpenInServiceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
}

// MARK: -
// MARK: Setup interface methods
extension OpenInServiceViewController {
    override func setupLayout() {
        self.view.addSubview(servicesTableView)
    }
    
    override func setupConstraints() {
        trackInfoTableHeaderView.snp.makeConstraints { make in
            make.height.equalTo(trackInfoTableHeaderView.height)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        servicesTableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}

// MARK: -
// MARK: OpenInServiceViewProtocol
extension OpenInServiceViewController: OpenInServiceViewProtocol {
    func reloadData() {
        self.servicesTableView.reloadData()
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension OpenInServiceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ServiceTableViewCell.id, for: indexPath)
        (cell as? ServiceTableViewCell)?.configure(withLink: self.presenter.links[indexPath.row])
        return cell
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension OpenInServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.presenter.didSelectItem(at: indexPath)
    }
}
