//
//  WebviewService.swift
//  stock_app
//
//  Created by Brian Li on 5/1/24.
//

//import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var htmlContent: String  // HTML content as a string

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
                webView.scrollView.isScrollEnabled = false // Disable vertical scroll
                return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

