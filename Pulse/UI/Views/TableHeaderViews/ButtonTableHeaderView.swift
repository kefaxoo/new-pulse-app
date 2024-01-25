//
//  ButtonTableHeaderView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.12.23.
//

import UIKit
import PulseUIComponents

final class ButtonTableHeaderView: BaseUIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("All", for: .normal)
        button.setImage(Constants.Images.chevronRight.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 15)), for: .normal)
        button.setTitleColor(.systemGray2, for: .normal)
        button.tintColor = .systemGray2
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 6
        button.configuration = configuration
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        return button
    }()
    
    private var completion: (() -> ())?
    
    @discardableResult func configure(withType type: ArtistViewScheme) -> Self {
        self.titleLabel.text = type.headerTitle
        return self
    }
    
    @discardableResult func configure<T>(
        withWidget widget: PulseWidget<T>,
        shouldShowButton: Bool = true,
        completion: @escaping(() -> ())
    ) -> Self where T: Decodable {
        self.titleLabel.text = Localization.Server.Widgets(rawValue: widget.localizationKey)?.localization ?? widget.title
        self.actionButton.setTitle(
            Localization.Server.Widgets.Button(rawValue: widget.buttonLocalizationKey)?.localization ?? widget.buttonText,
            for: .normal
        )
        
        self.actionButton.isHidden = !shouldShowButton
        self.completion = completion
        return self
    }
    
    @discardableResult func configure(
        withTitle title: String?,
        buttonText: String?,
        shouldShowButton: Bool = true,
        completion: @escaping(() -> ())
    ) -> Self {
        self.titleLabel.text = title
        self.actionButton.setTitle(buttonText, for: .normal)
        
        self.actionButton.isHidden = !shouldShowButton
        self.completion = completion
        return self
    }
}

// MARK: -
// MARK: Setup interface
extension ButtonTableHeaderView {
    override func setupInterface() {
        super.setupInterface()
        self.backgroundColor = .systemBackground
    }
    
    override func setupLayout() {
        self.addSubview(titleLabel)
        self.addSubview(actionButton)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 10))
        }
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalTo(titleLabel.snp.trailing).offset(20)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }
}

// MARK: -
// MARK: Actions
private extension ButtonTableHeaderView {
    @objc func buttonDidTap(_ sender: UIButton) {
        self.completion?()
    }
}
