//
//  AccountBlockedViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.01.24.
//

import UIKit
import PulseUIComponents

final class AccountBlockedViewController: BaseUIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.Controllers.AccountBlocked.Label.title.localization
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.Controllers.AccountBlocked.Label.description.localization
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        return stackView
    }()
}

// MARK: -
// MARK: Setup interface
extension AccountBlockedViewController {
    override func setupLayout() {
        self.view.addSubview(contentStackView)
    }
    
    override func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(horizontal: 16)
        }
    }
}
