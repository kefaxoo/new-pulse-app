//
//  MarqueeView.swift
//
//
//  Created by Bahdan Piatrouski on 1.01.24.
//

import UIKit

open class MarqueeView: UIView {
    public static var `default`: MarqueeView {
        let view = MarqueeView()
        view.marqueeType = .reverse
        view.pointsPerFrame = 0.1
        return view
    }
    
    public enum MarqueeType {
        case left
        case right
        case reverse
    }
    
    // MARK: - Private variables
    private lazy var containerView = UIView()
    
    private var marqueeDisplayLink: CADisplayLink?
    private var isReversing       = false
    
    // MARK: - Public variables
    public var marqueeType                          : MarqueeType = .left
    public var contentMargin                        : CGFloat = 12
    public var pointsPerFrame                       : CGFloat = 0.5
    public var frameInterval                        : Int = 1
    public var contentViewFrameConfigWhenCantMarquee: ((UIView) -> ())?
    public var contentView                          : UIView? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview == nil else { return }
        
        self.stopMarquee()
    }
    
    public init() {
        super.init(frame: .zero)
        
        self.configViews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.configViews() 
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let contentView else { return }
        
        containerView.subviews.forEach({ $0.removeFromSuperview() })
        
        contentView.sizeToFit()
        containerView.addSubview(contentView)
        
        var width = contentView.bounds.width
        if marqueeType != .reverse {
            width *= 2
        }
        
        containerView.frame = CGRect(
            origin: .zero, size: CGSize(width: width, height: self.bounds.height)
        )
        
        if contentView.bounds.width > self.bounds.width {
            contentView.frame = CGRect(
                origin: .zero,
                size: CGSize(
                    width: contentView.bounds.width,
                    height: self.bounds.height
                )
            )
            
            if marqueeType != .reverse {
                guard let otherContentView = contentView.copyMarqueeView() else { return }
                
                otherContentView.frame = CGRect(
                    x: contentView.bounds.width,
                    y: 0,
                    width: contentView.bounds.width,
                    height: self.bounds.height
                )
                
                containerView.addSubview(otherContentView)
            }
            
            guard self.bounds.width != 0 else { return }
            
            self.startMarquee()
        } else {
            if contentViewFrameConfigWhenCantMarquee != nil {
                contentViewFrameConfigWhenCantMarquee?(contentView)
            } else {
                contentView.frame = CGRect(origin: .zero, size: CGSize(width: contentView.bounds.width, height: self.bounds.height))
            }
        }
    }
}

// MARK: -
// MARK: Private methods
private extension MarqueeView {
    func configViews() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        
        self.containerView.backgroundColor = .clear
        self.addSubview(containerView)
    }
}

// MARK: -
// MARK: Control marquee
private extension MarqueeView {
    func startMarquee() {
        self.stopMarquee()
        
        guard self.containerView.bounds.width > self.bounds.width else { return }
        
        if marqueeType == .right {
            var frame = self.containerView.frame
            frame.origin.x = self.bounds.size.width - frame.size.width
            self.containerView.frame = frame
        }
        
        self.marqueeDisplayLink = CADisplayLink(target: self, selector: #selector(processMarquee))
        self.marqueeDisplayLink?.frameInterval = self.frameInterval
        self.marqueeDisplayLink?.add(to: .main, forMode: .common)
    }
    
    func stopMarquee() {
        self.marqueeDisplayLink?.invalidate()
        self.marqueeDisplayLink = nil
    }
    
    @objc func processMarquee() {
        guard let contentView else { return }
        var frame = self.containerView.frame
        
        switch marqueeType {
            case .left:
                let targetX = -(contentView.bounds.width + self.contentMargin)
                if frame.origin.x <= targetX {
                    frame.origin.x = 0
                } else {
                    frame.origin.x -= pointsPerFrame
                    if frame.origin.x < targetX {
                        frame.origin.x = targetX
                    }
                }
            case .right:
                let targetX = self.bounds.width - contentView.bounds.width
                if frame.origin.x >= targetX {
                    frame.origin.x = self.bounds.width - containerView.bounds.width
                } else {
                    frame.origin.x += pointsPerFrame
                    if frame.origin.x > targetX {
                        frame.origin.x = targetX
                    }
                }
            case .reverse:
                if isReversing {
                    if frame.origin.x > 0 {
                        frame.origin.x = 0
                        isReversing = false
                    } else {
                        frame.origin.x += pointsPerFrame
                        if frame.origin.x > 0 {
                            frame.origin.x = 0
                            isReversing = false
                        }
                    }
                } else {
                    let targetX = self.bounds.width - self.containerView.bounds.width
                    if frame.origin.x <= targetX {
                        isReversing = true
                    } else {
                        frame.origin.x -= pointsPerFrame
                        if frame.origin.x < targetX {
                            frame.origin.x = targetX
                            isReversing = true
                        }
                    }
                }
        }
        
        self.containerView.frame = frame
    }
}

// MARK: -
// MARK: Public methods
public extension MarqueeView {
    func reloadData() {
        self.setNeedsLayout()
    }
}
