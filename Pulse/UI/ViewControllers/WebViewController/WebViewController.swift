//
//  WebViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import UIKit
import WebKit

class WebViewController: BaseUIViewController {
    private lazy var navigationView = UIView(with: .systemBackground)
    
    private lazy var navigationTitle: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(SettingsManager.shared.color.color, for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()
    
    private var webView: WKWebView?
    
    private let presenter: WebPresenter
    
    private func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        debugLog("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                debugLog("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
    
    weak var delegate: WebViewControllerDelegate? {
        willSet {
            self.presenter.delegate = newValue
        }
    }
    
    init(type: WebViewType) {
        self.presenter = WebPresenter(type: type)
        super.init(nibName: nil, bundle: nil)
        self.presenter.viewDelegate = self
        
        self.isModalInPresentation = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Lifecycle
extension WebViewController {
    override func loadView() {
        super.loadView()
        self.presenter.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clean()
        self.presenter.viewDidLoad()
        self.presenter.observe(webView: self.webView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.presenter.viewDidDisappear()
    }
}

// MARK: -
// MARK: Setup interface methods
extension WebViewController {
    override func setupLayout() {
        self.view.addSubview(navigationView)
        navigationView.addSubview(navigationTitle)
        navigationView.addSubview(cancelButton)
        
        guard let webView else {
            self.dismiss(animated: true)
            return
        }
        
        self.view.addSubview(webView)
    }
    
    override func setupConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        navigationTitle.snp.makeConstraints({ $0.centerX.centerY.equalToSuperview() })
        
        cancelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        webView?.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: -
// MARK: Actions
fileprivate extension WebViewController {
    @objc func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: -
// MARK: WebPresenterDelegate
extension WebViewController: WebPresenterDelegate {
    func setupConfiguration(_ configuration: WKWebViewConfiguration) {
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView?.navigationDelegate = self
    }
    
    func load(with urlRequest: URLRequest) {
        self.webView?.load(urlRequest)
    }
    
    func changeNavigationTitle(to link: String) {
        self.navigationTitle.text = link
    }
    
    func dismissVC(animated: Bool) {
        self.dismiss(animated: true)
    }
}

// MARK: -
// MARK: WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let wkNavigationActionPolicy = WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2) else { return }
        
        decisionHandler(wkNavigationActionPolicy)
    }
}
