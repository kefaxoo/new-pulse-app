//
//  UITableView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import UIKit

extension UITableView {
    func register(_ cells: AnyClass...) {
        cells.forEach { [weak self] cell in
            let id = String(describing: cell.self)
            self?.register(cell, forCellReuseIdentifier: id)
        }
    }
}
