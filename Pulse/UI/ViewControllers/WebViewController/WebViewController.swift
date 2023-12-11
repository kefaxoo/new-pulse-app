//
//  WebViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import UIKit
import WebKit
import PulseUIComponents

class WebViewController: PageNavigationViewController {
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
        super.init(buttonTitleColor: SettingsManager.shared.color.color)
        self.presenter.viewDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buttonTitleColor = SettingsManager.shared.color.color
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
        super.setupLayout()
        guard let webView else {
            self.dismiss(animated: true)
            return
        }
        
        self.view.addSubview(webView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        webView?.snp.makeConstraints { make in
            make.top.equalTo(navigationViewConstraintItem)
            make.leading.trailing.bottom.equalToSuperview()
        }
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
        self.navigationTitle = link
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

@available(iOS 17.0, *)
#Preview {
    return WebViewController(type: .soundcloud)
}
