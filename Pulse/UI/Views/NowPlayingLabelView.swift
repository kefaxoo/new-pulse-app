//
//  NowPlayingLabelView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 12.03.24.
//

import UIKit
import PulseUIComponents

final class NowPlayingLabelView: BaseUIView {
    private lazy var labelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = SettingsManager.shared.color.color
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = SettingsManager.shared.color.color
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.addArrangedSubview(labelImageView)
        stackView.addArrangedSubview(textLabel)
        return stackView
    }()
    
    func updateLabel(isHiddenWithAnimation: Bool = true) {
        let label = AudioPlayer.shared.track?.nowPlayingLabel
        self.smoothIsHiddenAfterAlpha = label == nil
        guard let label else { return }
        
        self.backgroundColor = label != .dolbyAtmos ? SettingsManager.shared.color.color.withAlphaComponent(0.3) : .clear
        self.labelImageView.image = label.image
        self.textLabel.text = label.text
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingLabelView {
    override func setupInterface() {
        super.setupInterface()
        
        self.layer.cornerRadius = 3
    }
    
    override func setupLayout() {
        self.addSubview(contentStackView)
    }
    
    override func setupConstraints() {
        labelImageView.snp.makeConstraints({ $0.height.width.equalTo(contentStackView.snp.height) })
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 6, vertical: 3))
            make.height.equalTo(textLabel.size().height)
        }
    }
}
