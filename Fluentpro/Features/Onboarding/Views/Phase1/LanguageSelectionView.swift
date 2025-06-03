//
//  LanguageSelectionView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Header
            VStack(spacing: Theme.spacing.small) {
                Text("What's your native language?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("This helps us tailor your learning experience")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.spacing.xxxLarge)
            
            // Language Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                    ForEach(Language.allCases) { language in
                        LanguageCard(
                            language: language,
                            isSelected: viewModel.onboardingData.nativeLanguage == language,
                            action: {
                                viewModel.selectLanguage(language)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.spacing.small) {
                Text(language.flag)
                    .font(.system(size: 40))
                
                Text(language.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .theme.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacing.large)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                    .fill(isSelected ? Color.theme.primary : Color.theme.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                    .stroke(isSelected ? Color.theme.primary : Color.theme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}