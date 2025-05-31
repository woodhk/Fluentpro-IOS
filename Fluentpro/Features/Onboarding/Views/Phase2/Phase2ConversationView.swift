//
//  Phase2ConversationView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct Phase2ConversationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isMessageFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ConversationHeader()
            
            Divider()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Theme.spacing.medium) {
                        ForEach(viewModel.conversationMessages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isAITyping {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.conversationMessages.count) { _ in
                    withAnimation {
                        if let lastMessage = viewModel.conversationMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        } else {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            VStack(spacing: Theme.spacing.medium) {
                if viewModel.showContinueButton {
                    Button(action: {
                        viewModel.continueFromConversation()
                    }) {
                        Text("Continue to Course Selection")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                MessageInputView(
                    text: $viewModel.userMessageText,
                    isLoading: viewModel.isAITyping,
                    sendAction: {
                        viewModel.sendMessage()
                    }
                )
                .focused($isMessageFieldFocused)
                .disabled(viewModel.showContinueButton)
            }
            .padding(.bottom)
            .background(Color.theme.background)
        }
        .onAppear {
            // Send initial AI message
            if viewModel.conversationMessages.isEmpty {
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                    viewModel.isAITyping = true
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second typing
                    
                    let welcomeMessage = AIConversationMessage(
                        content: "Hello! I'm here to understand your English communication needs better. Can you tell me about your typical workday and the types of interactions you have with colleagues or clients?",
                        isUser: false
                    )
                    viewModel.conversationMessages.append(welcomeMessage)
                    viewModel.onboardingData.conversationMessages = viewModel.conversationMessages
                    viewModel.isAITyping = false
                }
            }
        }
    }
}

struct ConversationHeader: View {
    var body: some View {
        VStack(spacing: Theme.spacing.small) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.largeTitle)
                .foregroundColor(.theme.primary)
            
            Text("Let's understand your needs")
                .font(.headline)
            
            Text("Tell me about your work and communication challenges")
                .font(.caption)
                .foregroundColor(.theme.secondaryText)
        }
        .padding()
    }
}

struct MessageBubble: View {
    let message: AIConversationMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: Theme.spacing.xxSmall) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .theme.primaryText)
                    .padding(.horizontal, Theme.spacing.medium)
                    .padding(.vertical, Theme.spacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius.large)
                            .fill(message.isUser ? Color.theme.primary : Color.theme.secondaryBackground)
                    )
                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.theme.tertiaryText)
            }
            
            if !message.isUser { Spacer() }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animatingDot = 0
    
    var body: some View {
        HStack {
            HStack(spacing: Theme.spacing.xxSmall) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.theme.secondaryText)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animatingDot == index ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animatingDot
                        )
                }
            }
            .padding(.horizontal, Theme.spacing.medium)
            .padding(.vertical, Theme.spacing.small)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.large)
                    .fill(Color.theme.secondaryBackground)
            )
            
            Spacer()
        }
        .onAppear {
            animatingDot = 0
        }
    }
}

struct MessageInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let sendAction: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.spacing.small) {
            TextField("Type your message...", text: $text, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, Theme.spacing.medium)
                .padding(.vertical, Theme.spacing.small)
                .background(Color.theme.secondaryBackground)
                .cornerRadius(Theme.cornerRadius.large)
                .lineLimit(1...3)
                .onSubmit {
                    if !text.isEmpty && !isLoading {
                        sendAction()
                    }
                }
            
            Button(action: sendAction) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(text.isEmpty || isLoading ? .theme.tertiaryText : .theme.primary)
            }
            .disabled(text.isEmpty || isLoading)
        }
        .padding(.horizontal)
    }
}