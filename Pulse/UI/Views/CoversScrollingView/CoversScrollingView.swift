//
//  CoversScrollingView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import PulseUIComponents

class CoversScrollingView: BaseUIView {
    private lazy var coversStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var coversStackViewMarqueeView: MarqueeView = {
        return coversStackView.wrapIntoMarquee()
    }()
    
    private var covers = [PulseCover]()
    private var startFrom = 0
    
    func setupCovers(covers: [PulseCover], start: Int = 0) {
        self.covers = covers
        self.startFrom = start
        
        covers.forEach { [weak self] cover in
            let imageView = UIImageView.default
            imageView.setImage(from: cover.xl)
            imageView.layer.cornerRadius = 20
            imageView.snp.makeConstraints({ $0.width.height.equalTo(150) })
            self?.coversStackView.addArrangedSubview(imageView)
        }
        
        self.coversStackView.frame = CGRect(
            origin: .zero,
            size: CGSize(width: CGFloat((covers.count * 150) + ((covers.count - 1) * 20)), height: 150)
        )
        
        self.coversStackViewMarqueeView.contentMargin = 0
        self.coversStackViewMarqueeView.reloadData()
    }
}

// MARK: -
// MARK: Setup interface methods
extension CoversScrollingView {
    override func setupLayout() {
        self.addSubview(coversStackViewMarqueeView)
    }
    
    override func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.coversStackViewMarqueeView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}
