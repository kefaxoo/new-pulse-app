//
//  PageNavigationViewController.swift
//
//
//  Created by Bahdan Piatrouski on 22.11.23.
//

import UIKit
import SnapKit

open class PageNavigationViewController: BaseUIViewController {
    private lazy var navigationTitleLabel = UILabel()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var navigationView: UIView = {
        let view = UIView(color: .clear)
        view.addSubview(navigationTitleLabel)
        view.addSubview(cancelButton)
        return view
    }()
    
    public var buttonTitleColor: UIColor {
        didSet {
            cancelButton.setTitleColor(buttonTitleColor, for: .normal)
        }
    }
    
    public var navigationTitle: String? {
        didSet {
            self.navigationTitleLabel.text = navigationTitle
        }
    }
    
    public var navigationViewConstraintItem: ConstraintItem {
        return self.navigationView.snp.bottom
    }
    
    public init(buttonTitleColor: UIColor) {
        self.buttonTitleColor = buttonTitleColor
        super.init(nibName: nil, bundle: nil)
        self.isModalInPresentation = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension PageNavigationViewController {
    open override func setupLayout() {
        self.view.addSubview(navigationView)
    }
    
    open override func setupConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        navigationTitleLabel.snp.makeConstraints({ $0.centerX.centerY.equalToSuperview() })
        
        cancelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: -
// MARK: Actions
fileprivate extension PageNavigationViewController {
    @objc func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
