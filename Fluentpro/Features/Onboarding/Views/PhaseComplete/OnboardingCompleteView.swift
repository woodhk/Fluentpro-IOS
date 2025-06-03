//
//  OnboardingCompleteView.swift
//  Fluentpro
//
//  Created on 03/06/2025.
//

import SwiftUI

struct OnboardingCompleteView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showConfetti = false
    @State private var logoScale: CGFloat = 0.1
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.theme.background,
                    Color.theme.accent.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing.xxxLarge) {
                Spacer()
                
                // Success Icon with animation
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.theme.success)
                    .scaleEffect(logoScale)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: logoScale)
                
                // Main Content
                VStack(spacing: Theme.spacing.large) {
                    Text("Onboarding Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.primaryText)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .animation(.easeIn(duration: 0.8).delay(0.3), value: textOpacity)
                    
                    Text("Your personalized learning journey is ready")
                        .font(.title3)
                        .foregroundColor(.theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .animation(.easeIn(duration: 0.8).delay(0.5), value: textOpacity)
                    
                    // Summary of collected data
                    VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                        if let language = viewModel.onboardingData.nativeLanguage {
                            SummaryRow(icon: "globe", label: "Native Language", value: language.rawValue)
                        }
                        
                        if let industry = viewModel.onboardingData.industry {
                            SummaryRow(icon: "building.2", label: "Industry", value: industry.rawValue)
                        }
                        
                        if let role = viewModel.onboardingData.selectedRole {
                            SummaryRow(icon: "person.fill", label: "Role", value: role.title)
                        } else if viewModel.onboardingData.didSelectNoMatch {
                            SummaryRow(icon: "person.fill", label: "Role", value: viewModel.onboardingData.roleTitle)
                        }
                        
                        if !viewModel.onboardingData.selectedConversationPartners.isEmpty {
                            SummaryRow(
                                icon: "person.3.fill",
                                label: "Communication Partners",
                                value: "\(viewModel.onboardingData.selectedConversationPartners.count) selected"
                            )
                        }
                    }
                    .padding()
                    .background(Color.theme.surface)
                    .cornerRadius(Theme.cornerRadius.medium)
                    .opacity(textOpacity)
                    .animation(.easeIn(duration: 0.8).delay(0.7), value: textOpacity)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Enter Fluentpro Button
                Button(action: {
                    viewModel.enterFluentpro()
                }) {
                    HStack {
                        Text("Enter Fluentpro")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, Theme.spacing.xxxLarge)
                .opacity(textOpacity)
                .animation(.easeIn(duration: 0.8).delay(1.0), value: textOpacity)
            }
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Animate elements appearing
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
            }
            
            withAnimation {
                textOpacity = 1.0
            }
            
            // Show confetti
            withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
                showConfetti = true
            }
            
            // Hide confetti after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showConfetti = false
                }
            }
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: Theme.spacing.medium) {
            Image(systemName: icon)
                .foregroundColor(.theme.accent)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.theme.tertiaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.theme.primaryText)
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(confettiPieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(piece.position)
                    .opacity(piece.opacity)
                    .animation(
                        Animation.linear(duration: piece.duration)
                            .repeatCount(1, autoreverses: false),
                        value: piece.position
                    )
            }
        }
        .onAppear {
            createConfetti()
        }
    }
    
    func createConfetti() {
        let colors: [Color] = [Color.theme.accent, Color.theme.success, Color.yellow, Color.orange, Color.purple]
        
        for _ in 0..<100 {
            let piece = ConfettiPiece(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -20
                ),
                opacity: Double.random(in: 0.7...1.0),
                duration: Double.random(in: 2...4)
            )
            
            confettiPieces.append(piece)
            
            // Animate falling
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].position.y = UIScreen.main.bounds.height + 20
                    confettiPieces[index].opacity = 0
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
    let duration: Double
}