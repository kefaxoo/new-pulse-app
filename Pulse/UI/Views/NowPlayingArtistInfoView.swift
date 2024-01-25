//
//  NowPlayingArtistInfoView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.12.23.
//

import UIKit
import PulseUIComponents

final class NowPlayingArtistInfoView: BaseUIView {
    private lazy var artistImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private var tapClosure: (() -> ())?
    
    var artist: ArtistModel? {
        didSet {
            self.artistLabel.text = artist?.name
            self.artistImageView.setImage(from: artist?.image?.small)
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAction)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTapClosure(_ closure: @escaping(() -> ())) {
        self.tapClosure = closure
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingArtistInfoView {
    override func setupLayout() {
        self.addSubview(artistImageView)
        self.addSubview(artistLabel)
    }
    
    override func setupConstraints() {
        self.artistImageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        self.artistLabel.snp.makeConstraints { make in
            make.leading.equalTo(artistImageView.snp.trailing).offset(16)
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}

// MARK: -
// MARK: Actions
fileprivate extension NowPlayingArtistInfoView {
    @objc func didTapAction(_ sender: UITapGestureRecognizer) {
        self.tapClosure?()
    }
}
