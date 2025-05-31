//
//  WelcomeView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.xxxLarge) {
            Spacer()
            
            // Logo/Icon
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 100))
                .foregroundColor(.theme.primary)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
            
            // Main Content
            VStack(spacing: Theme.spacing.large) {
                Text("Welcome to FluentPro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("AI Business English Training\nTailored to Your Role")
                    .font(.title3)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.continueFromWelcome()
            }) {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
        .padding(.horizontal)
    }
}

struct IntroView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.xxxLarge) {
            Spacer()
            
            // Icon
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 80))
                .foregroundColor(.theme.primary)
            
            // Main Content
            VStack(spacing: Theme.spacing.large) {
                Text("Starting with the basics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Let's start tailoring your curriculum with some basic questions")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing.medium)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.continueFromIntro()
            }) {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
        .padding(.horizontal)
    }
}