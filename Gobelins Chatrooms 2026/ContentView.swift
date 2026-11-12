//
//  ContentView.swift
//  Gobelins Chatrooms 2026
//
//  Created by Léo Mouraire on 09/11/2026.
//

import SwiftUI

struct ContentView: View {
    private let hubURL = URL(string: "https://gobelins-chartooms-2026.netlify.app/")!

    // Open the saved chatroom directly if one was remembered
    @State private var chatroom: Chatroom? = Chatroom.saved

    var body: some View {
        ZStack {
            // The hub stays loaded underneath so it keeps its state when coming back
            LoadingWebView(url: hubURL, loadingMessage: "Loading chatrooms…", onOpenChatroom: { chatroom, remember in
                Chatroom.saved = remember ? chatroom : nil
                self.chatroom = chatroom
            })
            .ignoresSafeArea()

            if let chatroom {
                ChatroomView(chatroom: chatroom, onClose: {
                    // Going back to the launcher forgets the saved choice, so it shows again next time
                    Chatroom.saved = nil
                    self.chatroom = nil
                })
                    .id(chatroom.id)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.smooth, value: chatroom)
        #if os(iOS)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)   // hides the home indicator
        #endif
        #if os(macOS)
        .onAppear {
            DispatchQueue.main.async {
                NSApp.windows.first?.toggleFullScreen(nil) // real fullscreen at launch
            }
        }
        #endif
    }
}

struct ChatroomView: View {
    let chatroom: Chatroom
    let onClose: () -> Void

    var body: some View {
        LoadingWebView(url: chatroom.url, loadingMessage: "Opening \(chatroom.name)…")
            .ignoresSafeArea()
            .overlay {
                GeometryReader { geometry in
                    CloseButton(action: onClose)
                        .position(Self.closeButtonPosition(in: geometry))
                }
            }
    }

    // Puts the button in the screen's top corner, outside the page content: next to the notch / Dynamic Island
    // in portrait, in the side margin in landscape, and a small margin from the corner when there's no inset
    private static func closeButtonPosition(in geometry: GeometryProxy) -> CGPoint {
        let insets = geometry.safeAreaInsets
        let x = max(insets.leading / 2, 32) - insets.leading
        let y = max(insets.top / 2, 24) - insets.top
        return CGPoint(x: x, y: y)
    }
}

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 28, height: 28)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        // Dark tint keeps the white cross readable on light pages as well as dark ones
        .glassEffect(.clear.tint(.black.opacity(0.35)).interactive(), in: .circle)
        .shadow(color: .black.opacity(0.15), radius: 4, y: 1)
        .padding(8) // larger touch target than the visible circle
        .contentShape(.rect)
        .keyboardShortcut(.cancelAction) // Escape on macOS
        .accessibilityLabel("Back to chatrooms")
    }
}
