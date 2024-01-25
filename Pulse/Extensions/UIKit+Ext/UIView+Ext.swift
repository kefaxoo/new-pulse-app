//
//  UIView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import PulseUIComponents

extension UIView {
    convenience init(with color: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = color
    }
    
    static let spacer = UIView(with: .clear)
    
    static var newSpacer: UIView {
        let view = UIView(with: .clear)
        view.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        return view
    }
    
    var smoothIsHidden: Bool {
        get {
            return self.isHidden
        }
        set {
            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
                self?.isHidden = newValue
            }
        }
    }
    
    var smoothIsHiddenWithAlpha: Bool {
        get {
            return self.alpha == 0
        }
        set {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = newValue ? 0 : 1
            }
        }
    }
    
    var smoothIsHiddenAfterAlpha: Bool {
        get {
            return self.isHidden
        } 
        set {
            if !newValue {
                self.isHidden = false
                self.smoothIsHiddenWithAlpha = false
            } else {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.alpha = 0
                } completion: { _ in
                    self.isHidden = true
                }
            }
        }
    }
}

extension UIView {
    func wrapIntoMarquee() -> MarqueeView {
        let view = MarqueeView.default
        view.contentView = self
        return view
    }
}

extension UIView {
    func addGradientBorder(firstColor: UIColor?, secondColor: UIColor?) {
        guard let firstColor,
              let secondColor
        else { return }
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: self.frame.size)
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
    }
}
