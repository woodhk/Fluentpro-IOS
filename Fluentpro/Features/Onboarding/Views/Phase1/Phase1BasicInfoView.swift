//
//  Phase1BasicInfoView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct Phase1BasicInfoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            // Progress Bar
            ProgressBar(currentStep: viewModel.currentBasicInfoStep.rawValue + 1, totalSteps: 3)
                .padding(.horizontal)
                .padding(.top)
            
            // Content based on current step
            Group {
                switch viewModel.currentBasicInfoStep {
                case .language:
                    LanguageSelectionView(viewModel: viewModel)
                case .industry:
                    IndustrySelectionView(viewModel: viewModel)
                case .role:
                    RoleInputView(viewModel: viewModel)
                case .roleConfirmation:
                    RoleConfirmationView(viewModel: viewModel)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentBasicInfoStep)
            
            // Navigation Buttons (except for role confirmation which has its own)
            if viewModel.currentBasicInfoStep != .roleConfirmation {
                HStack {
                    if viewModel.currentBasicInfoStep != .language {
                        Button(action: {
                            viewModel.previousBasicInfoStep()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.theme.primary)
                                .frame(width: 44, height: 44)
                                .background(Color.theme.secondaryBackground)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

// Progress Bar Component
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.small) {
            Text("Step \(currentStep) of \(totalSteps)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.theme.secondaryText)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.theme.tertiaryBackground)
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.theme.primary)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}