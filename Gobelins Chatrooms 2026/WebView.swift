//
//  WebView.swift
//  Gobelins Chatrooms 2026
//
//  Created by Léo Mouraire on 09/11/2026.
//

import SwiftUI
import WebKit

enum WebLoadState: Equatable {
    case loading
    case loaded
    case failed(message: String)
}

struct WebView {
    // Name of the script message handler the hub posts to (see src/utils/native.js in the hub project)
    static let openChatroomHandler = "openChatroom"

    let url: URL
    var onOpenChatroom: ((_ chatroom: Chatroom, _ remember: Bool) -> Void)? = nil
    // Reports the first load of the page (later navigations inside the page are ignored)
    var loadState: Binding<WebLoadState>? = nil
    // Increment to load the page again, e.g. after a failure
    var reloadToken = 0

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeWebView(context: Context) -> WKWebView {
        context.coordinator.onOpenChatroom = onOpenChatroom
        context.coordinator.loadState = loadState
        context.coordinator.reloadToken = reloadToken

        let configuration = WKWebViewConfiguration()
        if onOpenChatroom != nil {
            configuration.userContentController.add(context.coordinator, name: Self.openChatroomHandler)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        #if DEBUG
        webView.isInspectable = true // debug the page from Safari > Develop
        #endif
        #if os(iOS)
        webView.scrollView.contentInsetAdjustmentBehavior = .never // draw under the notch / home bar
        webView.scrollView.bounces = false
        #endif
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateWebView(_ webView: WKWebView, context: Context) {
        context.coordinator.onOpenChatroom = onOpenChatroom
        context.coordinator.loadState = loadState

        if reloadToken != context.coordinator.reloadToken {
            context.coordinator.reloadToken = reloadToken
            context.coordinator.hasLoaded = false
            context.coordinator.setLoadState(.loading)
            webView.load(URLRequest(url: url))
        }
    }

    static func dismantleWebView(_ webView: WKWebView) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: openChatroomHandler)
    }

    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var onOpenChatroom: ((_ chatroom: Chatroom, _ remember: Bool) -> Void)?
        var loadState: Binding<WebLoadState>?
        var reloadToken = 0
        var hasLoaded = false

        func setLoadState(_ state: WebLoadState) {
            guard loadState?.wrappedValue != state else { return }
            loadState?.wrappedValue = state
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == WebView.openChatroomHandler,
                  let chatroom = Chatroom(messageBody: message.body) else { return }
            let remember = (message.body as? [String: Any])?["remember"] as? Bool ?? false
            onOpenChatroom?(chatroom, remember)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            hasLoaded = true
            setLoadState(.loaded)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            handleFailure(error)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            handleFailure(error)
        }

        private func handleFailure(_ error: any Error) {
            // Cancelled loads (e.g. a redirect replacing the request) aren't real failures
            guard !hasLoaded, (error as NSError).code != NSURLErrorCancelled else { return }
            setLoadState(.failed(message: error.localizedDescription))
        }
    }
}

#if os(iOS)
extension WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView { makeWebView(context: context) }
    func updateUIView(_ uiView: WKWebView, context: Context) { updateWebView(uiView, context: context) }
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) { dismantleWebView(uiView) }
}
#else
extension WebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView { makeWebView(context: context) }
    func updateNSView(_ nsView: WKWebView, context: Context) { updateWebView(nsView, context: context) }
    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) { dismantleWebView(nsView) }
}
#endif
