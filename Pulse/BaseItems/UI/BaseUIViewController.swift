//
//  BaseUIViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

class BaseUIViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
}

// MARK: -
// MARK: Setup interface methods
extension BaseUIViewController {
    @objc func setupInterface() {
        self.view.backgroundColor = UIColor.systemBackground
        setupLayout()
        setupConstraints()
    }
    
    @objc func setupLayout() {}
    @objc func setupConstraints() {}
}

// MARK: -
// MARK: Keyboard

extension BaseUIViewController {
    fileprivate struct NewVariables {
        static var movingView: UIView?
        static var defaultOffset: CGFloat?
    }

    private var movingView: UIView? {
        get {
            return NewVariables.movingView
        }
        set {
            NewVariables.movingView = newValue
        }
    }
    
    private var defaultOffset: CGFloat? {
        get {
            return NewVariables.defaultOffset
        }
        set {
            NewVariables.defaultOffset = newValue
        }
    }
    
    func observeKeyboard(view: UIView?, defaultOffset: CGFloat? = nil) {
        self.movingView = view
        self.defaultOffset = defaultOffset
        self.setupKeyboardObservers()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, keyboardWillShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, keyboardWillShow: false)
    }
    
    // swiftlint:disable force_cast
    @objc func moveViewWithKeyboard(notification: NSNotification, keyboardWillShow: Bool) {
        // Keyboard's size
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        // Keyboard's animation duration
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        // Change the constant
        let showedOffset = (defaultOffset ?? 0) + keyboardHeight
        let hidingOffset = defaultOffset ?? 0
        self.movingView?.snp.updateConstraints({
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardWillShow ? showedOffset : hidingOffset)
        })
        
        // Animate the view the same way the keyboard animates
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // Update Constraints
            self?.view.layoutIfNeeded()
        }
        
        // Perform the animation
        animator.startAnimation()
    }
    // swiftlint:enable force_cast
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.dismissKeyboard()
    }
}
