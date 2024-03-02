//
//  SplashScreenViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.02.24.
//

import UIKit
import PulseUIComponents

final class SplashScreenViewController: BaseUIViewController {
    private lazy var logoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 26
        LogoColumnView.Column.allCases.forEach { column in
            let columnView = LogoColumnView(numberOfColumn: column)
            columnView.animate()
            stackView.addArrangedSubview(columnView)
        }
        
        return stackView
    }()
}

// MARK: -
// MARK: Setup interface methods
extension SplashScreenViewController {
    override func setupLayout() {
        self.view.addSubview(logoStackView)
    }
    
    override func setupConstraints() {
        logoStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(184)
            make.width.equalTo(202)
        }
    }
}
