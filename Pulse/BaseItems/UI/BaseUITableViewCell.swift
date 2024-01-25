//
//  BaseUITableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func reloadData()
    func reloadCells(at indexPaths: [IndexPath])
    func reloadCells(at section: Int)
}

extension TableViewCellDelegate {
    func reloadCells(at indexPaths: [IndexPath]) {}
    func reloadCells(at section: Int) {}
}

class BaseUITableViewCell: UITableViewCell {
    weak var delegate: TableViewCellDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupInterface()
    }
}

extension BaseUITableViewCell {
    @objc func setupInterface() {
        setupLayout()
        setupConstraints()
    }
    
    @objc func setupLayout() {}
    @objc func setupConstraints() {}
}
