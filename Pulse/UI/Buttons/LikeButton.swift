//
//  LikeButton.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.03.24.
//

import UIKit

final class LikeButton: UIButton {
    typealias ToggleCompletion = ((_ isLiked: Bool) -> ())
    
    private var _isLiked = false
    private let toggleCompletion: ToggleCompletion?
    
    private let unlikedImage = Constants.Images.addToLibraryNowPlaying
    private let likedImage = Constants.Images.inLibrary
    
    private let unlikedScale: CGFloat = 0.7
    private let likedScale: CGFloat = 1.3
    
    var isLiked: Bool {
        get {
            return self._isLiked
        }
        set {
            self._isLiked = newValue
            self.toggleCompletion?(newValue)
            self.animate()
        }
    }
    
    init(isLiked: Bool = false, toggleCompletion: ToggleCompletion? = nil) {
        self._isLiked = isLiked
        self.toggleCompletion = toggleCompletion
        
        super.init(frame: .zero)
        
        let newImage = self._isLiked ? self.likedImage : self.unlikedImage
        self.setImage(newImage.image, for: .normal)
        self.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonDidTap(_ sender: UIButton) {
        self.isLiked.toggle()
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            
            let newImage = self._isLiked ? self.likedImage : self.unlikedImage
            let newScale = self._isLiked ? self.likedScale : self.unlikedScale
            
            self.transform = self.transform.scaledBy(x: newScale, y: newScale)
            self.setImage(newImage.image, for: .normal)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.1) {
                self?.transform = .identity
            }
        }
    }
}
