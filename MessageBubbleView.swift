//
//  MessageBubbleView.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import SwiftUI
import AVKit

struct MessageBubbleView: View {
    let message: Message
    let settings: ChatSettings

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer()
                content
                    .padding(12)
                    .background(Color(hex: settings.userBubbleHex))
                    .foregroundColor(message.type == .text ? .white : .primary)
                    .cornerRadius(18)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                content
                    .padding(12)
                    .background(Color(hex: settings.aiBubbleHex))
                    .foregroundColor(.primary)
                    .cornerRadius(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var content: some View {
        switch message.type {
        case .text:
            Text(message.content)
                .font(.body)
        case .image:
            if let ui = message.image {
                VStack {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 220)
                        .cornerRadius(12)
                    if !message.content.isEmpty {
                        Text(message.content).font(.caption)
                    }
                }
            } else {
                Text("Image")
            }
        case .audio:
            if let fname = message.audioFileName {
                AudioPlayerView(fileName: fname)
            } else {
                Text("Voice message")
            }
        }
    }
}
