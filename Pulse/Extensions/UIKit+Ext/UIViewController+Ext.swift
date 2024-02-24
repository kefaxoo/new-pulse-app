//
//  UIViewController+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import AlertKit
import PulseUIComponents

extension UIViewController {
    fileprivate struct UIViewControllerStoredVariables {
        static var spinnerAlert: AlertAppleMusic16View?
        static var isSpinnerPresented = false
    }
    
    private var spinnerAlert: AlertAppleMusic16View? {
        get {
            return UIViewControllerStoredVariables.spinnerAlert
        }
        set {
            UIViewControllerStoredVariables.spinnerAlert = newValue
        }
    }
    
    var isSpinnerPresented: Bool {
        get {
            return UIViewControllerStoredVariables.isSpinnerPresented
        }
        set {
            UIViewControllerStoredVariables.isSpinnerPresented = newValue
        }
    }
    
    func presentSpinner() {
        guard !self.isSpinnerPresented else { return }
        
        spinnerAlert?.dismiss()
        spinnerAlert = AlertAppleMusic16View(title: "", subtitle: "", icon: .spinnerLarge)
        spinnerAlert?.dismissByTap = false
        spinnerAlert?.present(on: self.view)
        
        self.isSpinnerPresented = true
    }
    
    func dismissSpinner() {
        spinnerAlert?.dismiss()
        
        self.isSpinnerPresented = false
    }
}

extension UIViewController {
    func configureNavigationController(title: String? = nil, preferesLargeTitles: Bool = true) -> UINavigationController {
        if let title {
            self.navigationItem.title = title
        }
        
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.prefersLargeTitles = preferesLargeTitles
        navigationController.navigationBar.tintColor = SettingsManager.shared.color.color
        return navigationController
    }
}

extension UIViewController {
    static var empty: UIViewController {
        let vc = UIViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = .systemBackground
        return vc
    }
}

extension UIViewController {
    func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T : Comparable {
        return min(max(value, minimum), maximum)
    }
    
    func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }
}

extension UIViewController {
    var topScreenInset: CGFloat {
        return -(UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0))
    }
}
