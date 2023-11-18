//
//  BaseUITableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func reloadData()
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
