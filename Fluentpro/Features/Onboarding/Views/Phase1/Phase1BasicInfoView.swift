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
            // Content based on current step
            Group {
                switch viewModel.currentBasicInfoStep {
                case .language:
                    LanguageSelectionView(viewModel: viewModel)
                case .industry:
                    IndustrySelectionView(viewModel: viewModel)
                case .role:
                    RoleInputView(viewModel: viewModel)
                case .roleResult:
                    RoleMatchResultView(viewModel: viewModel)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentBasicInfoStep)
            
            // Navigation Buttons (except for role result which has its own)
            if viewModel.currentBasicInfoStep != .roleResult {
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

