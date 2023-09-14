//
//  StaticGradientView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

class StaticGradientView: UIView {

    private var startColor: UIColor = .white
    private var endColor: UIColor = .black
    private var startLocation: Double = 0
    private var endLocation: Double = 1
    private var isHorizontal = false
    private var isDiagonal = false
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        // swiftlint:disable force_cast
        return layer as! CAGradientLayer
        // swiftlint:enable force_cast
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.updateInterface()
    }
    
    func updateInterface() {
        self.updateColors()
        self.updateLocations()
        self.updatePoints()
    }
    
    func updateGradient(
        startColor: UIColor? = nil,
        endColor: UIColor? = nil,
        startLocation: Double? = nil,
        endLocation: Double? = nil,
        isHorizontal: Bool? = nil,
        isDiagonal: Bool? = nil
    ) {
        if let startColor {
            self.startColor = startColor
            self.updateColors()
        }
        
        if let endColor {
            self.endColor = endColor
            self.updateColors()
        }
        
        if let startLocation {
            self.startLocation = startLocation
            self.updateLocations()
        }
        
        if let endLocation {
            self.endLocation = endLocation
            self.updateLocations()
        }
        
        if let isHorizontal {
            self.isHorizontal = isHorizontal
            self.updatePoints()
        }
        
        if let isDiagonal {
            self.isDiagonal = isDiagonal
            self.updateColors()
        }
    }
    
    private func updatePoints() {
        if isHorizontal {
            gradientLayer.startPoint = isDiagonal ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = isDiagonal ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = isDiagonal ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = isDiagonal ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    
    private func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    
    private func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updatePoints()
        self.updateLocations()
        self.updateColors()
    }
}
