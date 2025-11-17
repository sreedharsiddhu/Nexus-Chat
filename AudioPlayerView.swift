//
//  AudioPlayerView.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let fileName: String
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        HStack {
            Button(action: toggle) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
            }
            Text("Voice")
        }
        .onDisappear { player?.stop() }
    }

    private func toggle() {
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                isPlaying = true
            } catch {
                print("audio play err", error)
            }
        } else {
            print("audio not found", url.path)
        }
    }
}
