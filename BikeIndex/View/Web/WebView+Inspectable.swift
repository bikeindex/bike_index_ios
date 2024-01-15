//
//  WebView+Inspectable.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import SwiftUI
import WebKit
import WebViewKit

extension WebView {
    static func inspectable(_ webView: WKWebView) -> Void {
        #if !RELEASE
        webView.isInspectable = true
        #endif
    }
}
