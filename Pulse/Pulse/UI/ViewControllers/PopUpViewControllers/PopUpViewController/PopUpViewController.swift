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
        button.setImage(Constants.Images.dismiss.image, for: .normal)
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
    
    var isViewOnScreen = false
    var closure: (() -> ())?
    
    weak var delegate: PopUpViewControllerDelegate?
    
    func setClosure(closure: @escaping(() -> ())) {
        self.closure = closure
    }
    
    func present() {
        MainCoordinator.shared.currentViewController?.present(self, animated: false)
    }
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
    
    func dismissView() {
        isViewOnScreen = false
        mainView.snp.removeConstraints()
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(left: 16, right: 16))
            make.top.equalTo(self.view.snp.bottom).offset(20)
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.backgroundColor = UIColor.clear
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.closure?()
    }
}

// MARK: -
// MARK: Setup interface methods
extension PopUpViewController {
    override func setupLayout() {
        super.setupLayout()
        self.view.addSubview(mainView)
        mainView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(navigationView)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(dismissButton)
    }
    
    override func setupConstraints() {
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 16))
            make.top.equalTo(self.view.snp.bottom).offset(20)
        }
        
        mainStackView.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 16, vertical: 10)) })
        
        navigationView.snp.makeConstraints({ $0.height.equalTo(50) })
        titleLabel.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        dismissButton.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.trailing.equalToSuperview()
        }
    }
}

// MARK: -
// MARK: Actions
extension PopUpViewController {
    @objc private func dismissAction() {
        dismissView()
    }
}
