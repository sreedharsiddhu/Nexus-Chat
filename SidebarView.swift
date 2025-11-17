//
//  SidebarView.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var showMenu: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Chat History")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: { showMenu = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
            .overlay(Divider(), alignment: .bottom)

            Button(action: {
                viewModel.newConversation()
                showMenu = false
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Chat")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
            .padding([.horizontal, .top], 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.conversations) { conversation in
                        Button(action: {
                            viewModel.loadConversation(conversation)
                            showMenu = false
                        }) {
                            HStack {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 12))
                                Text(conversation.title)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            Spacer()
        }
        .frame(maxWidth: 280)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .vertical)
    }
}
