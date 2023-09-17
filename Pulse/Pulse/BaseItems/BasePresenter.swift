//
//  BasePresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

protocol BasePresenter {
    func loadView()
    func viewDidLoad()
    func viewWillAppear()
    func viewDidDisappear()
    func setupCell(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
    func setupCell(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell
}

extension BasePresenter {
    func loadView() {}
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewDidDisappear() {}
    func setupCell(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func setupCell(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
