//
//  ArtistTableHeaderView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 27.12.23.
//

import UIKit
import PulseUIComponents

final class ArtistTableHeaderView: BaseUIView {
    private lazy var canvasView: CanvasView = {
        let view = CanvasView()
        if let imageLink = self.artist.image?.original {
            view.setCanvas(from: imageLink, canvasType: .image)
        }
        
        return view
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50, weight: .semibold)
        label.numberOfLines = 0
        label.text = self.artist.name
        return label
    }()
    
    private let artist: ArtistModel
    
    init(artist: ArtistModel) {
        self.artist = artist
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension ArtistTableHeaderView {
    override func setupLayout() {
        self.addSubview(canvasView)
        self.addSubview(artistLabel)
    }
    
    override func setupConstraints() {
        canvasView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        artistLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 16))
        }
    }
}
