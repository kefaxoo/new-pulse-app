//
//  UIWindow+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 9.11.23.
//

import UIKit

extension UIWindow {
    class TransitionOptions: NSObject, CAAnimationDelegate {
        enum Curve {
            case linear
            case easeIn
            case easeOut
            case easeInOut
            
            var function: CAMediaTimingFunction {
                let key: CAMediaTimingFunctionName
                switch self {
                    case .linear:
                        key = CAMediaTimingFunctionName.linear
                    case .easeIn:
                        key = CAMediaTimingFunctionName.easeIn
                    case .easeOut:
                        key = CAMediaTimingFunctionName.easeOut
                    case .easeInOut:
                        key = CAMediaTimingFunctionName.easeInEaseOut
                }
                
                return CAMediaTimingFunction(name: key)
            }
        }
        
        enum Direction {
            case fade
            case toTop
            case toBottom
            case toLeft
            case toRight
            
            var transition: CATransition {
                let transition = CATransition()
                transition.type = .push
                switch self {
                    case .fade:
                        transition.type = .fade
                        transition.subtype = nil
                    case .toTop:
                        transition.subtype = .fromTop
                    case .toBottom:
                        transition.subtype = .fromBottom
                    case .toLeft:
                        transition.subtype = .fromLeft
                    case .toRight:
                        transition.subtype = .fromRight
                }
                
                return transition
            }
        }
        
        enum Background {
            case solidColor(_: UIColor)
            case customView(_: UIView)
        }
        
        var duration: TimeInterval = 0.2
        
        var direction: TransitionOptions.Direction = .toRight
        
        var style: TransitionOptions.Curve = .linear
        
        var background: TransitionOptions.Background?
        
        var completionBlock: ((Bool) -> ())?
        
        weak var previousVC: UIViewController?
        
        init(direction: TransitionOptions.Direction = .toRight, style: TransitionOptions.Curve = .linear) {
            self.direction = direction
            self.style = style
        }
        
        var animation: CATransition {
            let transition = direction.transition
            transition.duration = self.duration
            transition.timingFunction = self.style.function
            transition.delegate = self
            return transition
        }
        
        func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
            let oldNavigationController = previousVC as? UINavigationController
            oldNavigationController?.viewControllers = []
            
            completionBlock?(flag)
        }
    }
    
    func setRootVC(_ vc: UIViewController, options: TransitionOptions = TransitionOptions(), _ completion: ((Bool) -> ())? = nil) {
        let previousVC = rootViewController
        
        layer.add(options.animation, forKey: kCATransition)
        options.completionBlock = completion
        options.previousVC = previousVC
        
        rootViewController = vc
        
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                vc.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            vc.setNeedsStatusBarAppearanceUpdate()
        }
        
        if #unavailable(iOS 13.0) {
            if let transitionViewClass = NSClassFromString("UITransitionView") {
                subviews.filter({ $0.isKind(of: transitionViewClass) }).forEach({ $0.removeFromSuperview() })
            }
        }
        
        if let previousVC {
            previousVC.dismiss(animated: false) {
                previousVC.view.removeFromSuperview()
            }
        }
    }
}
