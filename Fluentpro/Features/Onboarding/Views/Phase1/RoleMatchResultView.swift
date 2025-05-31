//
//  RoleMatchResultView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct RoleMatchResultView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Spacer()
            
            Group {
                switch viewModel.roleMatchResult {
                case .matched(let role):
                    RoleMatchedView(role: role)
                case .notMatched:
                    RoleNotMatchedView()
                case .none:
                    EmptyView()
                }
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.continueFromRoleResult()
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

struct RoleMatchedView: View {
    let role: Role
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.theme.success)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: true)
            
            // Title
            Text("We found your role")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.theme.primaryText)
                .multilineTextAlignment(.center)
            
            // Role Details Card
            VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                Text(role.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.primaryText)
                
                Text(role.description)
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                
                if !role.commonTasks.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacing.small) {
                        Text("Common tasks:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.theme.tertiaryText)
                        
                        ForEach(role.commonTasks.prefix(3), id: \.self) { task in
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
                    .padding(.top, Theme.spacing.small)
                }
            }
            .padding()
            .cardStyle()
        }
    }
}

struct RoleNotMatchedView: View {
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Info Icon
            Image(systemName: "info.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.theme.warning)
            
            // Title
            Text("We didn't find a role match")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.theme.primaryText)
                .multilineTextAlignment(.center)
            
            // Description
            VStack(spacing: Theme.spacing.medium) {
                Text("No worries! We'll create a personalized curriculum just for you.")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("Your unique role will help us design courses that match your specific needs.")
                    .font(.subheadline)
                    .foregroundColor(.theme.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.spacing.medium)
        }
    }
}