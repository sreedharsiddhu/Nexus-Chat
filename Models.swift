//
//  Models.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import Foundation
import UIKit

// MARK: - Message & Conversation Models

enum MessageType: String, Codable {
    case text
    case image
    case audio
}

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String // text or caption
    let isUser: Bool
    let timestamp: Date
    let type: MessageType
    let imageDataBase64: String? // optional base64 for images
    let audioFileName: String? // local filename for audio messages

    init(id: UUID = UUID(),
         content: String,
         isUser: Bool,
         timestamp: Date = Date(),
         type: MessageType = .text,
         imageData: Data? = nil,
         audioFileName: String? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.type = type
        self.imageDataBase64 = imageData?.base64EncodedString()
        self.audioFileName = audioFileName
    }

    var image: UIImage? {
        guard let b64 = imageDataBase64,
              let data = Data(base64Encoded: b64) else { return nil }
        return UIImage(data: data)
    }
}

struct Conversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date
}

// MARK: - Settings

struct ChatSettings: Codable {
    var wallpaperName: String? = nil // builtin asset name
    var wallpaperImageDataBase64: String? = nil // if user-picked image
    var blurEnabled: Bool = false
    var userBubbleHex: String = "#0A84FF"
    var aiBubbleHex: String = "#EEEEEE"
    var fontSize: Double = 15.0
    var themeMode: Int = 0 // 0 system, 1 light, 2 dark
}
