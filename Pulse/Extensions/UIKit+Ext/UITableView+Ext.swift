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
    
    func layoutHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let headerWidth = headerView.bounds.width
        let temporaryWidthConstraint = headerView.widthAnchor.constraint(equalToConstant: headerWidth)
        
        headerView.addConstraint(temporaryWidthConstraint)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let height = headerSize.height
        var frame = headerView.frame
        
        frame.size.height = height
        headerView.frame = frame
        
        headerView.removeConstraint(temporaryWidthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }
}
