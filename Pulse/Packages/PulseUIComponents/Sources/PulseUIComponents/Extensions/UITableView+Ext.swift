//
//  UITableView+Ext.swift
//
//
//  Created by Bahdan Piatrouski on 28.12.23.
//

import UIKit

extension UITableView {
    public func register(_ cells: AnyClass...) {
        cells.forEach { [weak self] cell in
            let id = String(describing: cell.self)
            self?.register(cell, forCellReuseIdentifier: id)
        }
    }
    
    public func register(headerFooterViews: AnyClass...) {
        headerFooterViews.forEach { [weak self] view in
            let id = String(describing: view.self)
            self?.register(view, forHeaderFooterViewReuseIdentifier: id)
        }
    }
}
