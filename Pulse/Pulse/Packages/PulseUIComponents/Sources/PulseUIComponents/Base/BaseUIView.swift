//
//  BaseUIView.swift
//  
//
//  Created by ios on 12.10.23.
//

import UIKit

open class BaseUIView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: -
// MARK: Setup interface methods
extension BaseUIView {
    @objc open func setupInterface() {
        self.setupLayout()
        self.setupConstraints()
    }
    
    @objc open func setupLayout() {}
    @objc open func setupConstraints() {}
}
