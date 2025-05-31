//
//  RoleInputView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct RoleInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isRoleTitleFocused: Bool
    @FocusState private var isRoleDescriptionFocused: Bool
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Header
            VStack(spacing: Theme.spacing.small) {
                Text("What's your role?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Tell us about your position and responsibilities")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.spacing.xxxLarge)
            
            // Form
            VStack(spacing: Theme.spacing.large) {
                // Role Title
                VStack(alignment: .leading, spacing: Theme.spacing.small) {
                    Text("Job Title")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.theme.secondaryText)
                    
                    TextField("e.g., Product Manager", text: $viewModel.onboardingData.roleTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isRoleTitleFocused)
                }
                
                // Role Description
                VStack(alignment: .leading, spacing: Theme.spacing.small) {
                    Text("Role Description")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.theme.secondaryText)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $viewModel.onboardingData.roleDescription)
                            .focused($isRoleDescriptionFocused)
                            .frame(minHeight: 100, maxHeight: 150)
                            .padding(8)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(Theme.cornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                        
                        if viewModel.onboardingData.roleDescription.isEmpty {
                            Text("Describe your main responsibilities and daily tasks...")
                                .font(.body)
                                .foregroundColor(.theme.tertiaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                // Error message
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.theme.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Search Button
                Button(action: {
                    isRoleTitleFocused = false
                    isRoleDescriptionFocused = false
                    viewModel.submitRole()
                }) {
                    HStack {
                        if viewModel.roleSearchInProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Find Similar Role")
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.canProceedInBasicInfo() || viewModel.roleSearchInProgress)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onTapGesture {
            isRoleTitleFocused = false
            isRoleDescriptionFocused = false
        }
    }
}

// Role Confirmation View
struct RoleConfirmationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Header
            VStack(spacing: Theme.spacing.small) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.theme.success)
                
                Text("We found a matching role!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.spacing.xxxLarge)
            
            // Matched Role Card
            if let matchedRole = viewModel.onboardingData.matchedRole {
                VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                    Text(matchedRole.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(matchedRole.description)
                        .font(.body)
                        .foregroundColor(.theme.secondaryText)
                    
                    if !matchedRole.commonTasks.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.spacing.small) {
                            Text("Common tasks:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.theme.tertiaryText)
                            
                            ForEach(matchedRole.commonTasks, id: \.self) { task in
                                HStack(spacing: Theme.spacing.small) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                        .foregroundColor(.theme.tertiaryText)
                                    Text(task)
                                        .font(.caption)
                                        .foregroundColor(.theme.secondaryText)
                                }
                            }
                        }
                    }
                }
                .padding()
                .cardStyle()
                .padding(.horizontal)
            }
            
            // Question
            Text("Is this your role?")
                .font(.headline)
                .padding(.top)
            
            // Action Buttons
            HStack(spacing: Theme.spacing.medium) {
                Button(action: {
                    viewModel.confirmRole(false)
                }) {
                    Text("No, this isn't my role")
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button(action: {
                    viewModel.confirmRole(true)
                }) {
                    Text("Yes, this is my role")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}