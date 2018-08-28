//
//  ClashWebViewContoller.swift
//  ClashX
//
//  Created by CYC on 2018/8/28.
//  Copyright © 2018年 west2online. All rights reserved.
//

import Cocoa
import WebKit

class ClashWebViewContoller: NSViewController {
    let  webview: WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.uiDelegate = self
        webview.navigationDelegate = self
        self.view.addSubview(webview)
        
        let attributes:[NSLayoutConstraint.Attribute] = [.top,.left,.bottom,.right,.top]
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: webview, attribute: attribute, relatedBy: .equal, toItem: self.view, attribute: attribute, multiplier: 1, constant: 0);
            view.addConstraint(constraint)
        }
    
        
        // defaults write com.west2online.ClashX webviewUrl "your url"
        let url = UserDefaults.standard.string(forKey: "webviewUrl") ?? "http://127.0.0.1:8080"
        self.webview.load(URLRequest(url: URL(string: url)!))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.titleVisibility = .hidden
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.styleMask.insert(.fullSizeContentView)
        
        NSApp.activate(ignoringOtherApps: true)
        self.view.window?.makeKeyAndOrderFront(self)
        

    }
    
}

extension ClashWebViewContoller:WKUIDelegate,WKNavigationDelegate {
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.log(msg: "\(navigation)", level: .debug)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.log(msg: "\(error)", level: .debug)
    }
}
