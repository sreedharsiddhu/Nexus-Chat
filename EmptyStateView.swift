//
//  EmptyStateView.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.right.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            Text("Start Your Chat")
                .font(.system(size: 24, weight: .semibold))
            Text("Ask me anything you want. I'm here to help!")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
