//
//  UserVerificationWebViewVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import WebKit

class UserVerificationWebViewVC: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var url: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }

        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        if let urlString = self.url, let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
        
    }

}

extension UserVerificationWebViewVC: WKNavigationDelegate, WKUIDelegate {
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        print("navigationAction = \(navigationAction.request.url?.absoluteString)")
        if let url = navigationAction.request.url,
           url.scheme == "nippuracademy",
           url.host == "telegram-success" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                CacheClient.shared.isAccountVerified = true
                AppCoordinator.shared.setRoot(to: .main)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
        
}
