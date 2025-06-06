//
//  Phase1CompleteView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct Phase1CompleteView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var celebrationScale: CGFloat = 0.1
    
    var body: some View {
        VStack(spacing: Theme.spacing.xxxLarge) {
            Spacer()
            
            // Main Content
            VStack(spacing: Theme.spacing.large) {
                Text("Phase 1 Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                // Celebration Emoji
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(celebrationScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: celebrationScale)
                
                Text("Great! Now let's understand your communication context to personalize your learning experience")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing.medium)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.continueFromPhase1Complete()
            }) {
                Text("Continue to Phase 2")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
        .padding(.horizontal)
        .onAppear {
            // Animate celebration emoji
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                celebrationScale = 1.0
            }
        }
    }
}

struct Phase2CompleteView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var celebrationScale: CGFloat = 0.1
    
    var body: some View {
        VStack(spacing: Theme.spacing.xxxLarge) {
            Spacer()
            
            // Main Content
            VStack(spacing: Theme.spacing.large) {
                Text("Phase 2 Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                // Celebration Emoji
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(celebrationScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: celebrationScale)
                
                Text("Perfect! We now have all the information we need to create your personalized learning journey")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing.medium)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.continueFromPhase2Complete()
            }) {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
        .padding(.horizontal)
        .onAppear {
            // Animate celebration emoji
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                celebrationScale = 1.0
            }
        }
    }
}