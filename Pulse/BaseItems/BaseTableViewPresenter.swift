//
//  BaseTableViewPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

protocol BaseTableViewPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell
    func didSelectRow(at indexPath: IndexPath)
}

extension BaseTableViewPresenter {
    func didSelectRow(at indexPath: IndexPath) {}
}
