//
//  AlertView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import AlertKit
import UIKit

final class AlertView {
    static let shared = AlertView()
    
    private var lastAlert16: AlertAppleMusic16View?
    private var lastAlert17: AlertAppleMusic17View?
    fileprivate init() {}
    
    func present(title: String? = nil, message: String? = nil, alertType: AlertIcon, system: AlertViewStyle) {
        self.dismiss()
        
        guard let view = MainCoordinator.shared.currentViewController?.view else { return }
        switch system {
            case .iOS16AppleMusic:
                lastAlert16 = AlertAppleMusic16View(title: title, subtitle: message, icon: alertType)
                lastAlert16?.present(on: view)
            case .iOS17AppleMusic:
                lastAlert17 = AlertAppleMusic17View(title: title, subtitle: message, icon: alertType)
                lastAlert17?.present(on: view)
        }
    }
    
    func presentError(error: String? = nil, system: AlertViewStyle) {
        self.present(title: Localization.Words.error.localization, message: error, alertType: .error, system: system)
    }
    
    func dismiss() {
        lastAlert16?.dismiss()
        lastAlert17?.dismiss()
    }
}
