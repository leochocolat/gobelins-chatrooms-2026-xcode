//
//  LoadingWebView.swift
//  Gobelins Chatrooms 2026
//
//  Created by Léo Mouraire on 12/11/2026.
//

import SwiftUI

// Web view hidden behind a loading screen until its page is ready, with a retry when it fails
struct LoadingWebView: View {
    let url: URL
    let loadingMessage: String
    var onOpenChatroom: ((_ chatroom: Chatroom, _ remember: Bool) -> Void)? = nil

    @State private var loadState = WebLoadState.loading
    @State private var reloadToken = 0

    var body: some View {
        ZStack {
            Color.black

            WebView(url: url, onOpenChatroom: onOpenChatroom, loadState: $loadState, reloadToken: reloadToken)
                .opacity(loadState == .loaded ? 1 : 0)

            switch loadState {
            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                    Text(loadingMessage)
                        .font(.headline)
                }
                .transition(.opacity)

            case .failed(let message):
                VStack(spacing: 12) {
                    Text("This page didn't load")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)
                    Button("Try again") { reloadToken += 1 }
                        .buttonStyle(.glass)
                        .padding(.top, 8)
                }
                .padding()
                .transition(.opacity)

            case .loaded:
                EmptyView()
            }
        }
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
        .animation(.easeOut(duration: 0.3), value: loadState)
    }
}
