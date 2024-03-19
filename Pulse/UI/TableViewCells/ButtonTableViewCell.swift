//
//  ButtonTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit

class ButtonTableViewCell: BaseUITableViewCell {
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .label.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var mainButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.type.buttonName, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = .tinted()
        button.showsMenuAsPrimaryAction = self.type.isMenu
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private var type: SettingType = .none
    private var indexPath = IndexPath(row: 0, section: 0)
    
    func setupCell(type: SettingType, indexPath: IndexPath) {
        self.type = type
        self.indexPath = indexPath
        
        self.selectionStyle = type.selectionStyle
        self.titleLabel.text = type.title
        self.descriptionLabel.text = type.description
        self.mainButton.setTitle(type.buttonName, for: .normal)
        self.mainButton.showsMenuAsPrimaryAction = type.isMenu
        
        self.setupButton()
    }
}

// MARK: -
// MARK: Lifecycle
extension ButtonTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let color = SettingsManager.shared.color.color
        self.mainButton.menu = nil
        self.mainButton.showsMenuAsPrimaryAction = false
        self.mainButton.tintColor = color
        
        self.setupButton()
    }
}

// MARK: -
// MARK: Setup interface methods
extension ButtonTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.setupButton()
    }
    
    override func setupLayout() {
        self.contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        self.contentView.addSubview(mainButton)
    }
    
    override func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        mainButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(self.contentStackView.snp.trailing).offset(16)
            make.centerY.equalTo(self.contentStackView.snp.centerY)
        }
    }
    
    private func setupButton() {
        var actions = [UIAction]()
        switch self.type {
            case .accentColor:
                ColorType.allCases.forEach { [weak self] color in
                    let action = UIAction(title: color.title, state: color.isEqual(to: SettingsManager.shared.color)) { [weak self] _ in
                        SettingsManager.shared.color = color
                        PulseProvider.shared.updateSettings()
                        self?.delegate?.reloadData()
                    }
                    
                    actions.append(action)
                }
            case .soundcloudSource:
                SoundcloudSourceType.allCases.forEach { [weak self] soundcloudSource in
                    let action = UIAction(
                        title: soundcloudSource.buttonTitle,
                        state: soundcloudSource.isEqual(to: SettingsManager.shared.soundcloud.currentSource)
                    ) { [weak self] _ in
                        SettingsManager.shared.soundcloud.currentSource = soundcloudSource
                        PulseProvider.shared.updateSettings()
                        guard let self else { return }
                        
                        self.delegate?.reloadCells(at: [self.indexPath])
                    }
                    
                    actions.append(action)
                }
            case .appEnvironment:
                AppEnvironment.allCases.forEach { [weak self] appEnvironment in
                    let action = UIAction(title: appEnvironment.buttonTitle, state: appEnvironment == AppEnvironment.current ? .on : .off) { _ in
                        AppEnvironment.current = appEnvironment
                        guard let self else { return }
                        
                        self.delegate?.reloadCells(at: [self.indexPath])
                    }
                    
                    actions.append(action)
                }
            case .yandexMusicSource:
                YandexMusicSourceType.allCases.forEach { [weak self] yandexMusicSource in
                    let action = UIAction(
                        title: yandexMusicSource.buttonTitle,
                        state: yandexMusicSource.isEqual(to: SettingsManager.shared.yandexMusic.currentSource)
                    ) { _ in
                        SettingsManager.shared.yandexMusic.currentSource = yandexMusicSource
                        PulseProvider.shared.updateSettings()
                        guard let self else { return }
                        
                        self.delegate?.reloadCells(at: [self.indexPath])
                    }
                    
                    actions.append(action)
                }
            case .appearance:
                ApplicationStyle.allCases.forEach { [weak self] style in
                    let action = UIAction(title: style.title, state: style.isEqual(to: SettingsManager.shared.appearance)) { _ in
                        SettingsManager.shared.appearance = style
                        PulseProvider.shared.updateSettings()
                        guard let self else { return }
                        
                        self.delegate?.reloadCells(at: [self.indexPath])
                    }
                    
                    actions.append(action)
                }
            case .yandexMusicStreamingQuality:
                YandexMusicModel.Quality.allCases.forEach { [weak self] quality in
                    let action = UIAction(
                        title: quality.title,
                        state: quality.isEqual(to: SettingsManager.shared.yandexMusic.streamingQuality)
                    ) { _ in
                        SettingsManager.shared.yandexMusic.streamingQuality = quality
                        PulseProvider.shared.updateSettings()
                        guard let self else { return }
                        
                        self.delegate?.reloadCells(at: [self.indexPath])
                    }
                    
                    actions.append(action)
                }
            case .yandexMusicDownloadQuality:
                YandexMusicModel.Quality.allCases.forEach { [weak self] quality in
                    let action = UIAction(title: quality.title, state: quality.isEqual(to: SettingsManager.shared.yandexMusic.downloadQuality)) { _ in
                        SettingsManager.shared.yandexMusic.downloadQuality = quality
                        PulseProvider.shared.updateSettings()
                        guard let self else { return }
                        
                        self.delegate?.reloadCells(at: [self.indexPath])
                    }
                    
                    actions.append(action)
                }
            default:
                return
        }
        
        self.mainButton.menu = UIMenu(options: .displayInline, children: actions)
    }
}
