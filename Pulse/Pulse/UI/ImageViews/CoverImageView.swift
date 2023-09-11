//
//  CoverImageView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

enum CoverImageViewState {
    case loading
    case playing
    case paused
    case stopped
}

final class CoverImageView: UIImageView {
    private lazy var substrateView: UIView = {
        let view = UIView(with: .label.withAlphaComponent(0.5))
        view.isHidden = true
        return view
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.tintColor = SettingsManager.shared.color.color
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.setupInterface()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.setupInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
}

// MARK: -
// MARK: Setup interface methods
extension CoverImageView {
    private func setupInterface() {
        setupLayout()
        setupConstraints()
    }
    
    private func setupLayout() {
        self.addSubview(substrateView)
        substrateView.addSubview(activityIndicatorView)
    }
    
    private func setupConstraints() {
        
    }
}

// MARK: -
// MARK: State methods
extension CoverImageView {
    func changeState() {
        
    }
}
