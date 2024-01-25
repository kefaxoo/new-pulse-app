//
//  StoryCollectionViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import UIKit
import PulseUIComponents

final class StoryCollectionViewCell: BaseUICollectionViewCell {
    private lazy var trackImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 27
        return imageView
    }()
    
    private lazy var storyGradientView: StaticGradientView = {
        let view = StaticGradientView()
        view.updateGradient(startColor: .systemPurple, endColor: .systemMint)
        view.layer.cornerRadius = 30
        view.alpha = 0
        return view
    }()
    
    private lazy var storyView: UIView = {
        let view = UIView()
        view.addSubview(storyGradientView)
        view.addSubview(trackImageView)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.addArrangedSubview(storyView)
        stackView.addArrangedSubview(titleLabel)
        return stackView
    }()
    
    private var story: PulseStory?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.storyGradientView.alpha = 0
        self.titleLabel.text = nil
    }
    
    func configure(withStory story: PulseStory, trackCompletion: @escaping((TrackModel) -> ())) {
        self.story = story
        self.titleLabel.text = story.storyType.title
        let track = story.track
        switch track.source {
            case .muffon:
                MuffonProvider.shared.trackInfo(id: track.id, service: track.service) { [weak self] track in
                    let track = TrackModel(track)
                    trackCompletion(track)
                    self?.trackImageView.setImage(from: track.image?.small, completion: {
                        guard !story.didUserWatch else { return }
                        
                        self?.storyGradientView.smoothIsHiddenWithAlpha = false
                    })
                }
            case .soundcloud:
                SoundcloudProvider.shared.trackInfo(id: track.id) { [weak self] track in
                    let track = TrackModel(track)
                    trackCompletion(track)
                    self?.trackImageView.setImage(from: track.image?.small, completion: {
                        guard !story.didUserWatch else { return }
                        
                        self?.storyGradientView.smoothIsHiddenWithAlpha = false
                    })
                }
            case .yandexMusic:
                YandexMusicProvider.shared.trackInfo(id: track.id) { [weak self] track in
                    let track = TrackModel(track)
                    trackCompletion(track)
                    self?.trackImageView.setImage(from: track.image?.small, completion: {
                        guard !story.didUserWatch else { return }
                        
                        self?.storyGradientView.smoothIsHiddenWithAlpha = false
                    })
                }
            case .pulse:
                PulseProvider.shared.exclusiveTrackInfo(byId: track.id) { [weak self] track in
                    let track = TrackModel(track)
                    trackCompletion(track)
                    self?.trackImageView.setImage(from: track.image?.small, completion: {
                        guard !story.didUserWatch else { return }
                        
                        self?.storyGradientView.smoothIsHiddenWithAlpha = false
                    })
                } failure: { _, _ in }
            default:
                break
        }
    }
    
    class func height(withStory story: PulseStory) -> CGFloat {
        var height: CGFloat = 6 + 60 + 12
        height += story.storyType.title.height(withWidth: 60, font: .systemFont(ofSize: 13, weight: .light))
        return height
    }
}

// MARK: -
// MARK: Setup interface
extension StoryCollectionViewCell {
    override func setupLayout() {
        self.addSubview(contentVerticalStackView)
    }
    
    override func setupConstraints() {
        storyView.snp.makeConstraints({ $0.height.width.equalTo(60) })
        storyGradientView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        trackImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
            make.centerX.centerY.equalToSuperview()
        }
        
        contentVerticalStackView.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(vertical: 6)) })
    }
}

@available(iOS 17.0, *)
#Preview {
    return StoryCollectionViewCell()
}
