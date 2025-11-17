//
//  ChatViewModel.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import Foundation
import Combine
import SwiftUI
import AVFoundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading: Bool = false
    @Published var typingIndicator: Bool = false

    @Published var settings: ChatSettings = Persistence.loadSettings()

    private let apiClient = GroqApiClient()
    private var currentConversation: Conversation?
    private var recorder = VoiceRecorder()

    private var saveTimer: Timer?

    init() {
        conversations = Persistence.loadConversations()
        // If there is a conversation saved as first, load
        currentConversation = conversations.first
        messages = currentConversation?.messages ?? []
        // autosave timer to persist messages regularly
        saveTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.saveConversation()
        }
    }

    deinit { saveTimer?.invalidate() }

    // Send text message, save and call API
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = Message(content: content, isUser: true, type: .text)
        appendAndSave(userMessage)

        // Show typing indicator
        DispatchQueue.main.async {
            self.typingIndicator = true
            self.isLoading = true
        }

        apiClient.chat(message: content) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                self.typingIndicator = false
                switch result {
                case .success(let response):
                    let aiMessage = Message(content: response, isUser: false, type: .text)
                    self.appendAndSave(aiMessage)
                case .failure(let error):
                    let aiMessage = Message(content: "Error: \(error.localizedDescription)", isUser: false, type: .text)
                    self.appendAndSave(aiMessage)
                }
            }
        }
    }

    // Send image as message
    func sendImage(_ uiImage: UIImage, caption: String = "") {
        let data = uiImage.jpegData(compressionQuality: 0.8)
        let msg = Message(content: caption, isUser: true, type: .image, imageData: data)
        appendAndSave(msg)

        // Optionally call API with caption; here we send just the caption text if any
        if !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sendMessage(caption)
        }
    }

    // Voice recording helpers
    func startRecording() throws {
        try recorder.startRecording()
    }

    func stopRecordingAndSend() {
        guard let url = recorder.stopRecording() else { return }
        // create message with audio filename
        let filename = url.lastPathComponent
        let msg = Message(content: "Voice message", isUser: true, type: .audio, audioFileName: filename)
        appendAndSave(msg)
    }

    // Append message and save to current conversation
    private func appendAndSave(_ message: Message) {
        messages.append(message)
        saveConversation()
    }

    func newConversation() {
        // Save current conv
        saveConversation()
        messages = []
        currentConversation = nil
    }

    func loadConversation(_ conversation: Conversation) {
        currentConversation = conversation
        messages = conversation.messages
    }

    private func saveConversation() {
        guard !messages.isEmpty else { return }
        let title = messages.first?.content.prefix(30) ?? "New Chat"
        let conversation = Conversation(
            id: currentConversation?.id ?? UUID(),
            title: String(title),
            messages: messages,
            createdAt: currentConversation?.createdAt ?? Date()
        )
        currentConversation = conversation

        if let idx = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[idx] = conversation
        } else {
            conversations.insert(conversation, at: 0)
        }

        Persistence.saveConversations(conversations)
    }

    // Save settings
    func updateSettings(_ s: ChatSettings) {
        self.settings = s
        Persistence.saveSettings(s)
    }
}
