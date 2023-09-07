//
//  PlayPauseButton.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit

final class PlayPauseButton: UIControl {
    
    private(set) var isPlaying: Bool = false
    
    private let leftLayer: CAShapeLayer
    private let rightLayer: CAShapeLayer
    
    private let pauseButtonLineSpacing: CGFloat = 10
    
    private var leftPath: CGPath {
        guard isPlaying else { return leftLayerPausedPath }
        
        let bound = leftLayer.bounds
            .insetBy(dx: pauseButtonLineSpacing, dy: 0)
            .offsetBy(dx: -pauseButtonLineSpacing, dy: 0)
        
        return UIBezierPath(rect: bound).cgPath
    }
    
    private var rightPath: CGPath {
        guard isPlaying else { return rightLayerPausedPath }
        
        let bound = rightLayer.bounds
            .insetBy(dx: pauseButtonLineSpacing, dy: 0)
            .offsetBy(dx: pauseButtonLineSpacing, dy: 0)
        
        return UIBezierPath(rect: bound).cgPath
    }
    
    private var leftLayerPausedPath: CGPath {
        let y1 = leftLayerFrame.width * 0.5
        let y2 = leftLayerFrame.height - leftLayerFrame.width * 0.5
        
        let path = UIBezierPath()
        path.move(to:CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: leftLayerFrame.width, y: y1))
        path.addLine(to: CGPoint(x: leftLayerFrame.width, y: y2))
        path.addLine(to: CGPoint(x: 0, y: leftLayerFrame.height))
        path.close()
        
        return path.cgPath
    }
    
    private var rightLayerPausedPath: CGPath {
        let y1 = rightLayerFrame.width * 0.5
        let y2 = rightLayerFrame.height - leftLayerFrame.width * 0.5
        let path = UIBezierPath()
        
        path.move(to:CGPoint(x: 0, y: y1))
        path.addLine(to: CGPoint(x: rightLayerFrame.width, y: rightLayerFrame.height * 0.5))
        path.addLine(to: CGPoint(x: rightLayerFrame.width, y: rightLayerFrame.height * 0.5))
        path.addLine(to: CGPoint(x: 0, y: y2))
        path.close()
        
        return path.cgPath
    }
    
    private var leftLayerFrame: CGRect {
        return CGRect(x: 0, y: 0, width: bounds.width * 0.5, height: bounds.height)
    }
    
    private var rightLayerFrame: CGRect {
        return leftLayerFrame.offsetBy(dx: bounds.width * 0.5, dy: 0)
    }
    
    override var tintColor: UIColor! {
        didSet {
            leftLayer.fillColor = self.tintColor.cgColor
            rightLayer.fillColor = self.tintColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        self.leftLayer = CAShapeLayer()
        self.rightLayer = CAShapeLayer()
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        self.layer.addSublayer(leftLayer)
        self.layer.addSublayer(rightLayer)
        
        tintColor = SettingsManager.shared.color.color
        self.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }
    
    func setPlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
        self.animateLayer()
    }
    
    private func animateLayer() {
        let fromLeftPath = leftLayer.path
        let toLeftPath = leftPath
        leftLayer.path = toLeftPath
        
        let fromRightPath = rightLayer.path
        let toRightPath = rightPath
        rightLayer.path = toRightPath
        
        let leftPathAnimation = pathAnimation(fromPath: fromLeftPath, toPath: toLeftPath)
        let rightPathAnimation = pathAnimation(fromPath: fromRightPath, toPath: toRightPath)
        
        leftLayer.add(leftPathAnimation, forKey: nil)
        rightLayer.add(rightPathAnimation, forKey: nil)
    }
    
    private func pathAnimation(fromPath: CGPath?, toPath: CGPath) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.33
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.fromValue = fromPath
        animation.toValue = toPath
        return animation
    }
}

// MARK: -
// MARK: Life cycle
extension PlayPauseButton {
    override func layoutSubviews() {
        leftLayer.frame = leftLayerFrame
        rightLayer.frame = rightLayerFrame
        
        leftLayer.path = leftPath
        rightLayer.path = rightPath
    }
}

// MARK: -
// MARK: Actions
extension PlayPauseButton {
    @objc private func pressed() {
        self.setPlaying(!self.isPlaying)
    }
}
