//
//  PasswordTextField.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

final class PasswordTextField: UITextField {
    private lazy var hideButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: Constants.Images.System.eye)
        configuration.imagePadding = 5
        button.configuration = configuration
        button.tintColor = .label.withAlphaComponent(0.7)
        button.addTarget(self, action: #selector(hidePasswordAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
    
    init() {
        super.init(frame: .zero)
        self.placeholder = "Password"
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
        self.hideButton.setImage(
            UIImage(systemName: self.isSecureTextEntry ? Constants.Images.System.eye : Constants.Images.System.eyeWithSlash),
            for: .normal
        )
    }
}
