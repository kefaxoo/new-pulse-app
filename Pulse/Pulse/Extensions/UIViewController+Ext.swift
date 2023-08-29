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
    
    func presentSpinner() {
        spinnerAlert?.dismiss()
        spinnerAlert = AlertAppleMusic16View(title: "", subtitle: "", icon: .spinnerLarge)
        spinnerAlert?.dismissByTap = false
        spinnerAlert?.present(on: self.view)
    }
    
    func dismissSpinner() {
        spinnerAlert?.dismiss()
    }
}
