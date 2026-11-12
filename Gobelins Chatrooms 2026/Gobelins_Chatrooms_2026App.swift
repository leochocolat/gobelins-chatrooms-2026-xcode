//
//  Gobelins_Chatrooms_2026App.swift
//  Gobelins Chatrooms 2026
//
//  Created by Léo Mouraire on 09/11/2026.
//

import SwiftUI

@main
struct HelloWorldApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
