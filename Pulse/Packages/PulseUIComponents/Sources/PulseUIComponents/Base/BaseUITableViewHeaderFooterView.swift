//
//  BaseUITableViewHeaderFooterView.swift
//
//
//  Created by Bahdan Piatrouski on 28.12.23.
//

import UIKit

open class BaseUITableViewHeaderFooterView: UITableViewHeaderFooterView {
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupInterface()
    }
}

// MARK: -
// MARK: Setup interface methods
extension BaseUITableViewHeaderFooterView {
    @objc open func setupInterface() {
        self.setupLayout()
        self.setupConstraints()
    }
    
    @objc open func setupLayout() {}
    @objc open func setupConstraints() {}
}
