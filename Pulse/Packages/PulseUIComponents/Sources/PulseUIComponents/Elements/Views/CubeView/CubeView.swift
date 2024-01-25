//
//  CubeView.swift
//
//
//  Created by Bahdan Piatrouski on 20.01.24.
//

import UIKit
import SnapKit

public protocol CubeViewDelegate: AnyObject {
    func cubeViewDidScroll(_ cubeView: CubeView)
}

public extension CubeViewDelegate {
    func cubeViewDidScroll(_ cubeView: CubeView) {}
}

open class CubeView: UIScrollView, UIScrollViewDelegate {
    public weak var cubeViewDelegate: CubeViewDelegate?
    
    private let maxAngle: CGFloat = 60
    private var childViews = [UIView]()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.configureScrollView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureScrollView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func addChildViews(_ views: [UIView]) {
        views.forEach { [weak self] view in
            view.layer.masksToBounds = true
            self?.stackView.addArrangedSubview(view)
            guard let self else { return }
            
            view.snp.makeConstraints({ $0.width.equalTo(self.snp.width) })
            self.childViews.append(view)
        }
    }
    
    open func addChildView(_ view: UIView) {
        addChildViews([view])
    }
    
    open func scrollToViewAtIndex(_ index: Int, animated: Bool) {
        guard index > -1,
              index < self.childViews.count
        else { return }
        
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        let frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
        self.scrollRectToVisible(frame, animated: animated)
    }
    
    // MARK: Scroll view delegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.transformViewsInScrollView(scrollView)
        self.cubeViewDelegate?.cubeViewDidScroll(self)
    }
    
    // MARK: Private methods
    
    private func configureScrollView() {
        // Configure scroll view properties
        self.backgroundColor = .black
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isPagingEnabled = true
        self.bounces = true
        self.delegate = self
        
        // Add layout constraints
        self.addSubview(self.stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.height.equalTo(self.snp.height)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    private func transformViewsInScrollView(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let svWidth = scrollView.frame.width
        var deg = maxAngle / bounds.size.width * xOffset
        
        self.childViews.enumerated().forEach { [weak self] index, view in
            deg = index == 0 ? deg : deg - (self?.maxAngle ?? 60)
            let rad = deg * CGFloat(Double.pi / 180)
            
            var transform = CATransform3DIdentity
            transform.m34 = 1 / 500
            transform = CATransform3DRotate(transform, rad, 0, 1, 0)
            
            view.layer.transform = transform
            
            let x = xOffset / svWidth > CGFloat(index) ? 1.0 : 0.0
            self?.setAnchorPoint(CGPoint(x: x, y: 0.5), forView: view)
            
            self?.applyShadowForView(view, index: index)
        }
    }
    
    private func applyShadowForView(_ view: UIView, index: Int) {
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        let r1 = self.frameFor(origin: contentOffset, size: self.frame.size)
        let r2 = self.frameFor(origin: CGPoint(x: CGFloat(index) * w, y: 0), size: CGSize(width: w, height: h))
        
        // Only show shadow on right-hand side
        guard r1.origin.x <= r2.origin.x else { return }
        
        let intersection = r1.intersection(r2)
        let intArea = intersection.size.width * intersection.size.height
        let union = r1.union(r2)
        let unionArea = union.size.width * union.size.height
        
        view.layer.opacity = Float(intArea / unionArea)
    }
    
    private func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    private func frameFor(origin: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
}
