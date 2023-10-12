//
//  BaseUIViewController.swift
//  
//
//  Created by ios on 12.10.23.
//

import UIKit

class BaseUIViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        // Keyboard's size
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        // Keyboard's animation duration
        
    }
}
