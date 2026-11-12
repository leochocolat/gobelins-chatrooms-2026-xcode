//
//  Chatroom.swift
//  Gobelins Chatrooms 2026
//
//  Created by Léo Mouraire on 11/11/2026.
//

import Foundation

struct Chatroom: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let url: URL

    // Builds a chatroom from the body sent by the hub: { id, name, url }
    init?(messageBody: Any) {
        guard let body = messageBody as? [String: Any],
              let id = body["id"] as? String,
              let urlString = body["url"] as? String,
              let url = URL(string: urlString) else { return nil }

        self.id = id
        self.name = body["name"] as? String ?? id
        self.url = url
    }
}

// Chatroom to open directly at launch, chosen with "Don't show this next time" on the hub
extension Chatroom {
    private static let savedKey = "savedChatroom"

    static var saved: Chatroom? {
        get {
            guard let data = UserDefaults.standard.data(forKey: savedKey) else { return nil }
            return try? JSONDecoder().decode(Chatroom.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: savedKey)
            } else {
                UserDefaults.standard.removeObject(forKey: savedKey)
            }
        }
    }
}
