//
//  StaticGradientView.swift
//
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import UIKit

open class StaticGradientView: UIView {
    private var startColor: UIColor = .white {
        didSet {
            self.updateColors()
        }
    }
    
    private var endColor: UIColor = .black {
        didSet {
            self.updateColors()
        }
    }
    
    private var startLocation: Double = 0 {
        didSet {
            self.updateLocations()
        }
    }
    
    private var endLocation: Double = 1 {
        didSet {
            self.updateLocations()
        }
    }
    
    private var isHorizontal = false {
        didSet {
            self.updatePoints()
        }
    }
    
    private var isDiagonal = false {
        didSet {
            self.updateColors()
        }
    }
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        // swiftlint:disable force_cast
        return layer as! CAGradientLayer
        // swiftlint:enable force_cast
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.updateInterface()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.updateInterface()
    }
    
    private func updateInterface() {
        self.updateColors()
        self.updateLocations()
        self.updatePoints()
    }
    
    open func updateGradient(
        startColor   : UIColor? = nil,
        endColor     : UIColor? = nil,
        startLocation: Double?  = nil,
        endLocation  : Double?  = nil,
        isHorizontal : Bool?    = nil,
        isDiagonal   : Bool?    = nil
    ) {
        self.startColor = startColor ?? self.startColor
        self.endColor = endColor ?? self.endColor
        self.startLocation = startLocation ?? self.startLocation
        self.endLocation = endLocation ?? self.endLocation
        self.isHorizontal = isHorizontal ?? self.isHorizontal
        self.isDiagonal = isDiagonal ?? self.isDiagonal
    }
    
    private func updatePoints() {
        if isHorizontal {
            gradientLayer.startPoint = isDiagonal ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = isDiagonal ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = isDiagonal ? CGPoint.zero : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = isDiagonal ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    
    private func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    
    private func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateInterface()
    }
}
