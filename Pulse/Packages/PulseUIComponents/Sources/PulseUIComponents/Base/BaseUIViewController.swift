//
//  BaseUIViewController.swift
//  
//
//  Created by ios on 12.10.23.
//

import UIKit

open class BaseUIViewController: UIViewController {
    private var notificationNames = [Notification.Name]()

    public var screenIdUrl: URL?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserversIfNeeded()
        self.removeAllNotifications()
    }
}

// MARK: -
// MARK: Setup interface methods
extension BaseUIViewController {
    @objc open func setupInterface() {
        self.view.backgroundColor = UIColor.systemBackground
        self.setupLayout()
        self.setupConstraints()
    }
    
    @objc open func setupLayout() {}
    @objc open func setupConstraints() {}
}

// MARK: -
// MARK: Keyboard
extension BaseUIViewController {
    fileprivate struct NewVariables {
        static var movingView: UIView?
        static var defaultOffset: CGFloat?
    }
    
    fileprivate weak var movingView: UIView? {
        get {
            return NewVariables.movingView
        }
        set {
            NewVariables.movingView = newValue
        }
    }
    
    fileprivate var defaultOffset: CGFloat? {
        get {
            return NewVariables.defaultOffset
        }
        set {
            NewVariables.defaultOffset = newValue
        }
    }
    
    final public func configureKeyboardObservating(observeView view: UIView?, movingOffset offset: CGFloat? = nil) {
        self.movingView = view
        self.defaultOffset = offset
        self.setupKeyboardObservers()
    }
    
    fileprivate func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc fileprivate func keyboardWillAppear(_ sender: NSNotification) {
        self.moveViewWithKeyboard(notification: sender, willShow: true)
    }
    
    @objc fileprivate func keyboardWillDisappear(_ sender: NSNotification) {
        self.moveViewWithKeyboard(notification: sender, willShow: false)
    }
    
    fileprivate func moveViewWithKeyboard(notification: NSNotification, willShow: Bool) {
        // Keyboard's size, animation duration, animation cure
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
              let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let keyboardCurveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardCurve = UIView.AnimationCurve(rawValue: keyboardCurveRawValue)
        else { return }
        
        // Change the constant
        let showedOffset = (defaultOffset ?? 0) + keyboardHeight
        let hidingOffset = defaultOffset ?? 0
        self.movingView?.snp.updateConstraints({ $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(willShow ? showedOffset : hidingOffset) })
        
        // Animate the view the same way the keyboard animates
        UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }).startAnimation()
    }
    
    @objc open func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    fileprivate func removeKeyboardObserversIfNeeded() {
        guard self.movingView != nil else { return }
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension BaseUIViewController {
    fileprivate struct StatusBar {
        static var style: UIStatusBarStyle = .default
    }
    
    public var statusBarStyle: UIStatusBarStyle {
        get {
            return self.preferredStatusBarStyle
        }
        set {
            StatusBar.style = newValue
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBar.style
    }
}

extension BaseUIViewController {
    public func addNotification(name: Notification.Name, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
    
    private func removeAllNotifications() {
        self.notificationNames.forEach({ NotificationCenter.default.removeObserver(self, name: $0, object: nil) })
    }
}
