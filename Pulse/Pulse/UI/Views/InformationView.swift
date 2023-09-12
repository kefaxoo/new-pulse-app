//
//  InformationView.swift
//  Pulse
//
//  Created by ios on 12.09.23.
//

import UIKit

enum InformationStyles {
    case empty(title: String, description: String? = nil)
    case none
    
    var image: UIImage? {
        switch self {
            case .empty:
                return ConstantsEnum.Images.warning.image
            default:
                return nil
        }
    }
    
    var title: String? {
        switch self {
            case .empty(let title, _):
                return title
            default:
                return nil
        }
    }
    
    var description: String? {
        switch self {
            case .empty(_, let description):
                return description
            default:
                return nil
        }
    }
}

final class InformationView: BaseUIView {
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.tintColor = SettingsManager.shared.color.color
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.numberOfLines = 0
        return label
    }()
    
    private let style: InformationStyles
    
    init(style: InformationStyles) {
        self.style = style
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        self.style = .none
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        self.style = .none
        super.init(coder: coder)
    }
}

// MARK: -
// MARK: Setup interface methods
extension InformationView {
    override func setupInterface() {
        self.backgroundColor = .clear
        super.setupInterface()
        self.setupElements()
    }
    
    override func setupLayout() {
        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
    }
    
    override func setupConstraints() {
        mainStackView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        imageView.snp.makeConstraints({ $0.height.width.equalTo(mainStackView.snp.width) })
    }
    
    private func setupElements() {
        self.imageView.image = self.style.image
        self.titleLabel.text = self.style.title
        self.descriptionLabel.text = self.style.description
    }
}
