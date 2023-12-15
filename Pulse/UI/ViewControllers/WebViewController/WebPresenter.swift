//
//  WebPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation
import WebKit

protocol WebPresenterDelegate: AnyObject {
    func setupConfiguration(_ configuration: WKWebViewConfiguration)
    func load(with urlRequest: URLRequest)
    func dismissVC(animated: Bool)
    func changeNavigationTitle(to link: String)
}

protocol WebViewControllerDelegate: AnyObject {
    func viewDidDisappear()
}

final class WebPresenter: BasePresenter {
    private let type: WebViewType
    private var urlObservation: NSKeyValueObservation?
    
    weak var viewDelegate: WebPresenterDelegate?
    
    weak var delegate: WebViewControllerDelegate?
    
    init(type: WebViewType) {
        self.type = type
    }
    
    func loadView() {
        let configuration = WKWebViewConfiguration()
        if self.type != .none,
           !self.type.configureUserAgent.isEmpty {
            configuration.applicationNameForUserAgent = self.type.configureUserAgent
        }
        
        self.viewDelegate?.setupConfiguration(configuration)
    }
    
    func viewDidLoad() {
        guard let url = URL(string: type.initialLink) else {
            self.viewDelegate?.dismissVC(animated: true)
            return
        }
        
        self.viewDelegate?.load(with: URLRequest(url: url))
    }
    
    func viewDidDisappear() {
        self.delegate?.viewDidDisappear()
    }
    
    func observe(webView: WKWebView?) {
        urlObservation = webView?.observe(\.url, changeHandler: { [weak self] webView, _ in
            guard let self,
                  let url = webView.url?.absoluteString
            else { return }
            
            if let urlComponents = URLComponents(string: url) {
                self.viewDelegate?.changeNavigationTitle(to: urlComponents.host ?? "")
            }
            
            if url.contains(self.type.obserableLink) {
                if self.type.shouldUseURLComponents {
                    let urlComponents = URLComponents(string: url)
                    guard let fragment = urlComponents?.fragment else {
                        self.viewDelegate?.dismissVC(animated: true)
                        return
                    }
                    
                    let queryItemsArray = fragment.split(separator: "&").map({ String($0).split(separator: "=").map({ String($0) }) })
                    
                    guard let accessToken = queryItemsArray.first(where: { $0[0] == self.type.urlQueryComponent })?[1] else {
                        self.viewDelegate?.dismissVC(animated: true)
                        return
                    }
                    
                    self.type.saveSignToken(accessToken)
                    self.viewDelegate?.dismissVC(animated: true)
                } else {
                    let token = url.replacingOccurrences(of: self.type.obserableLink, with: "")
                    debugLog("Token:", token)
                    self.type.saveSignToken(token)
                    self.viewDelegate?.dismissVC(animated: true)
                }
            }
        })
    }
}
