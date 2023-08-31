//
//  PopUpViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 31.08.23.
//

import UIKit

protocol PopUpViewControllerDelegate: AnyObject {
    func reloadData()
}

class PopUpViewController: BaseUIViewController {
    lazy var mainView: UIView = {
        let view = UIView(with: .systemBackground)
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    lazy var navigationView = UIView(with: .clear)
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.Images.System.xInFilledCircle), for: .normal)
        button.tintColor = UIColor.label.withAlphaComponent(0.7)
        button.contentHorizontalAlignment = .trailing
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button.configuration = configuration
        return button
    }()
    
    lazy var titleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.insets = UIEdgeInsets(vertical: 10)
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    var closure: (() -> ())?
    
    weak var delegate: PopUpViewControllerDelegate?
    
    var isViewOnScreen = false
}

// MARK: -
// MARK: Life cycle
extension PopUpViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeKeyboard(view: self.mainView, defaultOffset: 20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.snp.removeConstraints()
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 16))
            make.bottom.equalToSuperview().offset(-20)
        }
        
        UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(0.7)
            self?.view.layoutIfNeeded()
        }.startAnimation()
        
        isViewOnScreen = true
    }
}

// MARK: -
// MARK: Actions
extension PopUpViewController {
    @objc private func dismissAction() {
        
    }
}

//class PopUpViewController: BaseUIViewController {
//    override func viewDidAppear(_ animated: Bool) {
//        mainView.snp.removeConstraints()
//        mainView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(left: 16, right: 16))
//            make.bottom.equalToSuperview().offset(-20)
//        }
//        
//        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
//            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//            self.view.layoutIfNeeded()
//        }
//        
//        animator.startAnimation()
//        isViewOnScreen = true
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.closure?()
//    }
//    
//    func set(closure: @escaping(() -> ())) {
//        self.closure = closure
//    }
//    
//    override func setupLayout() {
//        self.view.addSubview(mainView)
//        mainView.addSubview(mainStackView)
//        mainStackView.addArrangedSubview(navigationView)
//        navigationView.addSubview(titleLabel)
//        navigationView.addSubview(dismissButton)
//    }
//    
//    override func setupConstraints() {
//        mainView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(left: 16, right: 16))
//            make.top.equalTo(self.view.snp.bottom).offset(20)
//        }
//        
//        mainStackView.snp.makeConstraints({
//            $0.edges.equalToSuperview().inset(
//                UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
//            )
//        })
//        
//        navigationView.snp.makeConstraints({ $0.height.equalTo(50) })
//        titleLabel.snp.makeConstraints({ $0.edges.equalToSuperview() })
//        
//        dismissButton.snp.makeConstraints { make in
//            make.height.width.equalTo(50)
//            make.trailing.equalToSuperview()
//        }
//    }
//    
//    @objc private func dismissAction() {
//        dismissView()
//    }
//    
//    func dismissView() {
//        isViewOnScreen = false
//        mainView.snp.removeConstraints()
//        mainView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(left: 16, right: 16))
//            make.top.equalTo(self.view.snp.bottom).offset(20)
//        }
//        
//        UIView.animate(withDuration: 0.2) {
//            self.view.backgroundColor = UIColor.clear
//            self.view.layoutIfNeeded()
//        } completion: { isCompleted in
//            if isCompleted {
//                self.dismiss(animated: false)
//            }
//        }
//    }
//    
//    func present() {
//        self.currentVC?.present(self, animated: false)
//    }
//}

