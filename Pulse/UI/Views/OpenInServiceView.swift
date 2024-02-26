//
//  OpenInServiceView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import UIKit
import PulseUIComponents

final class OpenInServiceView: BaseUIView {
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.baselineAdjustment = .none
        return label
    }()
    
    private lazy var titleMarqueeView: MarqueeView = {
        return titleLabel.wrapIntoMarquee()
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.baselineAdjustment = .none
        return label
    }()
    
    private lazy var artistMarqueeView: MarqueeView = {
        return artistLabel.wrapIntoMarquee()
    }()
    
    private lazy var copyUrlButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Views.OpenInService.Buttons.copyUrl.localization, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = UIButton.Configuration.tinted()
        button.addTarget(self, action: #selector(copyToClipboardAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.Words.share.localization, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = UIButton.Configuration.tinted()
        button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.addArrangedSubview(copyUrlButton)
        stackView.addArrangedSubview(shareButton)
        return stackView
    }()
    
    var height: CGFloat {
        return UIScreen.main.bounds.width + 16 + titleLabel.size().height + 8 + artistLabel.size().height + 16 + UIButton.defaultHeight
    }
    
    var track: TrackModel?
    
    @discardableResult func configure(track: TrackModel) -> OpenInServiceView {
        self.coverImageView.setImage(from: track.image?.original)
        self.titleLabel.text = track.title
        self.artistLabel.text = track.artistText
        self.titleMarqueeView.reloadData()
        self.artistMarqueeView.reloadData()
        self.track = track
        
        return self
    }
}

// MARK: -
// MARK: Setup interface methods
extension OpenInServiceView {
    override func setupLayout() {
        self.addSubview(coverImageView)
        self.addSubview(titleMarqueeView)
        self.addSubview(artistMarqueeView)
        self.addSubview(buttonsStackView)
    }
    
    override func setupConstraints() {
        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.width.equalTo(UIScreen.main.bounds.width)
        }
        
        titleMarqueeView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 16))
            make.height.equalTo(titleLabel.size().height)
        }
        
        artistMarqueeView.snp.makeConstraints { make in
            make.top.equalTo(titleMarqueeView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 16))
            make.height.equalTo(artistLabel.size().height)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(artistMarqueeView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 16))
            make.height.equalTo(UIButton.defaultHeight)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: -
// MARK: Actions
private extension OpenInServiceView {
    @objc func copyToClipboardAction(_ sender: UIButton) {
        guard let shareLink = track?.shareLink else { return }
        
        UIPasteboard.general.string = shareLink
        AlertView.shared.present(title: "Share link was copied to clipboard", alertType: .done, system: .iOS17AppleMusic)
    }
    
    @objc func shareAction(_ sender: UIButton) {
        guard let track else { return }
        
        let text = Localization.Actions.ShareTrackAsLink.shareText.localization(with: track.title, track.artistText, track.shareLink)
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        MainCoordinator.shared.present(activityVC, animated: true)
    }
}
