//
//  UIViewController+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import AlertKit

fileprivate struct UIViewControllerStoredVariables {
    static var spinnerAlert: AlertAppleMusic16View?
    static var isSpinnerPresented = false
}

extension UIViewController {
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
