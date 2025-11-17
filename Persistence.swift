//
//  Persistence.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import Foundation

enum PersKeys {
    static let conversations = "com.app.conversations.v1"
    static let settings = "com.app.chat.settings.v1"
}

class Persistence {
    static func saveConversations(_ convos: [Conversation]) {
        if let data = try? JSONEncoder().encode(convos) {
            UserDefaults.standard.set(data, forKey: PersKeys.conversations)
        }
    }
    static func loadConversations() -> [Conversation] {
        guard let data = UserDefaults.standard.data(forKey: PersKeys.conversations),
              let convos = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return []
        }
        return convos
    }

    static func saveSettings(_ s: ChatSettings) {
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: PersKeys.settings)
        }
    }
    static func loadSettings() -> ChatSettings {
        guard let data = UserDefaults.standard.data(forKey: PersKeys.settings),
              let s = try? JSONDecoder().decode(ChatSettings.self, from: data) else {
            return ChatSettings()
        }
        return s
    }
}
