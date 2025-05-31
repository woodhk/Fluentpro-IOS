//
//  IndustrySelectionView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct IndustrySelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Header
            VStack(spacing: Theme.spacing.small) {
                Text("What industry do you work in?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("We'll customize your business English content")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.spacing.xxxLarge)
            
            // Industry List
            ScrollView {
                VStack(spacing: Theme.spacing.medium) {
                    ForEach(Industry.allCases) { industry in
                        IndustryRow(
                            industry: industry,
                            isSelected: viewModel.onboardingData.industry == industry,
                            action: {
                                viewModel.selectIndustry(industry)
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

struct IndustryRow: View {
    let industry: Industry
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.spacing.medium) {
                Image(systemName: industry.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .theme.primary)
                    .frame(width: 30)
                
                Text(industry.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .theme.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                    .fill(isSelected ? Color.theme.primary : Color.theme.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                    .stroke(isSelected ? Color.theme.primary : Color.theme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}