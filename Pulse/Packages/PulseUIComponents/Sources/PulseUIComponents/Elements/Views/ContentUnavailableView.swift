//
//  ContentUnavailableView.swift
//
//
//  Created by Bahdan Piatrouski on 14.11.23.
//

import UIKit

open class ContentUnavailableView: BaseUIView {
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    private lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.isHidden = true
        imageView.tintColor = .label
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.addArrangedSubview(loadingActivityIndicatorView)
        stackView.addArrangedSubview(contentImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        return stackView
    }()
    
    public var loadingTintColor: UIColor = .systemGray {
        didSet {
            self.loadingActivityIndicatorView.color = loadingTintColor
        }
    }
    
    public var contentImage: UIImage? {
        didSet {
            let isHidden: Bool
            if let systemImage = contentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50)) {
                isHidden = false
                self.contentImageView.image = systemImage
            } else if let image = contentImage?.resizeImage(to: CGSize(width: 100, height: 100)) {
                isHidden = false
                self.contentImageView.image = image
            } else {
                isHidden = true
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.contentImageView.isHidden = isHidden
            }
        }
    }
    
    public var contentImageColor: UIColor? {
        didSet {
            self.contentImageView.tintColor = contentImageColor
        }
    }
    
    public var titleText: String? {
        didSet {
            titleLabel.text = titleText
            DispatchQueue.main.async { [weak self] in
                self?.titleLabel.isHidden = self?.titleText == nil
            }
        }
    }
    
    public var titleTextColor: UIColor? = .systemGray {
        didSet {
            titleLabel.textColor = titleTextColor
        }
    }
    
    public var titleFont: UIFont? = .systemFont(ofSize: 25, weight: .semibold) {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    public var subtitleText: String? {
        didSet {
            subtitleLabel.text = subtitleText
            DispatchQueue.main.async { [weak self] in
                self?.subtitleLabel.isHidden = self?.subtitleText == nil
            }
        }
    }
    
    public var subtitleTextColor: UIColor? = .systemGray {
        didSet {
            subtitleLabel.textColor = subtitleTextColor
        }
    }
    
    public var subtitleFont: UIFont? = .systemFont(ofSize: 17) {
        didSet {
            subtitleLabel.font = subtitleFont
        }
    }
    
    private var isLoadingActivityIndicatorShowing = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }

    public init() {
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func loading(
        frame: CGRect = .zero,
        subtitleText: String? = nil,
        subtitleTextColor: UIColor? = .systemGray,
        subtitleFont: UIFont? = .systemFont(ofSize: 17)
    ) -> ContentUnavailableView {
        let view = ContentUnavailableView(frame: frame)
        view.subtitleText = subtitleText
        view.subtitleTextColor = subtitleTextColor
        view.subtitleFont = subtitleFont
        return view
    }
}

// MARK: -
// MARK: Loading activity indicator methods
public extension ContentUnavailableView {
    func startAnimating() {
        self.loadingActivityIndicatorView.startAnimating()
        self.isLoadingActivityIndicatorShowing = true
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.loadingActivityIndicatorView.isHidden = false
        }
    }
    
    func stopAnimating(_ completion: (() -> ())? = nil) {
        self.isLoadingActivityIndicatorShowing = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.loadingActivityIndicatorView.isHidden = true
        } completion: { [weak self] _ in
            self?.loadingActivityIndicatorView.stopAnimating()
            completion?()
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.contentStackView.alpha = 0
        } completion: { [weak self] _ in
            self?.isHidden = true
            self?.loadingActivityIndicatorView.stopAnimating()
        }
    }
    
    func show() {
        if self.isLoadingActivityIndicatorShowing {
            self.loadingActivityIndicatorView.startAnimating()
        }
        
        self.isHidden = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.contentStackView.alpha = 1
        }
    }
}

extension ContentUnavailableView {
    open override func setupLayout() {
        self.addSubview(contentStackView)
    }
    
    open override func setupConstraints() {
        contentStackView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        contentImageView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
        }
    }
}
