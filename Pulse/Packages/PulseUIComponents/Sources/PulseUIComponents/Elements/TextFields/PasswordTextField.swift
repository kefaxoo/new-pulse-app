//
//  PasswordTextField.swift
//
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit

final public class PasswordTextField: UITextField {
    private lazy var hideButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "eye")
        configuration.imagePadding = 5
        button.configuration = configuration
        button.addTarget(self, action: #selector(hidePasswordAction), for: .touchUpInside)
        return button
    }()
    
    override public var tintColor: UIColor! {
        didSet {
            hideButton.tintColor = tintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
    
    public init(tintColor: UIColor?, placeholder: String = "Password") {
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        self.tintColor = tintColor
        self.setupInterface()
    }
    
    private func setupInterface() {
        self.rightView = hideButton
        self.rightViewMode = .always
        self.isSecureTextEntry = true
        self.borderStyle = .roundedRect
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
    }
    
    @objc private func hidePasswordAction(_ sender: UIButton) {
        self.isSecureTextEntry.toggle()
        self.hideButton.setImage(UIImage(systemName: self.isSecureTextEntry ? "eye" : "eye.slash"), for: .normal)
    }
}
