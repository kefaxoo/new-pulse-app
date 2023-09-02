//
//  BaseUICollectionViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit

class BaseUICollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
}

extension BaseUICollectionViewCell {
    @objc func setupInterface() {
        setupLayout()
        setupConstraints()
    }
    
    @objc func setupLayout() {}
    @objc func setupConstraints() {}
}
