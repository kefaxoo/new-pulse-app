//
//  CoverImageView.swift
//
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit
import ESTMusicIndicator
import SnapKit
import SDWebImage

public enum CoverImageViewState {
    case loading
    case playing
    case paused
    case stopped
    
    var musicIndicatorState: ESTMusicIndicatorViewState {
        switch self {
            case .playing:
                return .playing
            case .paused:
                return .paused
            default:
                return .stopped
        }
    }
}

public class CoverImageView: UIImageView {
    private lazy var substrateView: UIView = {
        let view = UIView(color: .black.withAlphaComponent(0.5))
        view.isHidden = true
        return view
    }()
    
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    private lazy var musicIndicatorView: ESTMusicIndicatorView = {
        let musicIndicatorView = ESTMusicIndicatorView()
        musicIndicatorView.state = .stopped
        musicIndicatorView.isHidden = true
        return musicIndicatorView
    }()
    
    public var state: CoverImageViewState = .stopped {
        didSet {
            self.substrateView.basicHideAnimation(isHidden: self.state == .stopped)
            self.loadingActivityIndicatorView.basicHideAnimation(isHidden: self.state == .stopped)
            self.musicIndicatorView.basicHideAnimation(isHidden: self.state == .stopped)
            
            self.musicIndicatorView.state = self.state.musicIndicatorState
            self.loadingActivityIndicatorView.stopAnimating()
            switch self.state {
                case .loading:
                    if !self.musicIndicatorView.isHidden {
                        self.musicIndicatorView.basicHideAnimation(isHidden: true)
                    }
                    
                    self.loadingActivityIndicatorView.basicHideAnimation(isHidden: false)
                    self.loadingActivityIndicatorView.startAnimating()
                case .playing, .paused:
                    guard self.musicIndicatorView.isHidden else { break }
                    
                    if !self.loadingActivityIndicatorView.isHidden {
                        self.loadingActivityIndicatorView.basicHideAnimation(isHidden: true)
                    }
                    
                    self.musicIndicatorView.basicHideAnimation(isHidden: false)
                default:
                    break
            }
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            loadingActivityIndicatorView.color = self.tintColor
            musicIndicatorView.tintColor = self.tintColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        self.setupInterface()
    }
    
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.setupInterface()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
    
    public convenience init(tintColor: UIColor) {
        self.init(frame: .zero)
        self.tintColor = tintColor
        self.setupInterface()
    }
    
    public func reset() {
        self.loadingActivityIndicatorView.stopAnimating()
        self.loadingActivityIndicatorView.isHidden = true
        self.musicIndicatorView.isHidden = true
        self.musicIndicatorView.state = .stopped
        self.substrateView.isHidden = true
        self.image = nil
        self.sd_cancelCurrentImageLoad()
    }
}

// MARK: -
// MARK: Setup interface methods
private extension CoverImageView {
    func setupInterface() {
        self.layer.masksToBounds = true
        self.contentMode = .scaleAspectFit
        
        self.setupLayout()
        self.setupConstraints()
    }
    
    func setupLayout() {
        self.addSubview(substrateView)
        substrateView.addSubview(loadingActivityIndicatorView)
        substrateView.addSubview(musicIndicatorView)
    }
    
    func setupConstraints() {
        substrateView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        loadingActivityIndicatorView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        musicIndicatorView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}

fileprivate extension UIView {
    func basicHideAnimation(isHidden: Bool) {
        UIView.transition(with: self, duration: 1, options: .curveLinear) { [weak self] in
            self?.isHidden = isHidden
        }
    }
}
