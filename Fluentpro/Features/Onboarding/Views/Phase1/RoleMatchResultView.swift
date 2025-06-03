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
            Group {
                switch viewModel.roleMatchResult {
                case .matched(let roles):
                    RoleMatchedView(roles: roles, viewModel: viewModel)
                case .notMatched:
                    RoleNotMatchedView(viewModel: viewModel)
                case .none:
                    EmptyView()
                }
            }
        }
        .padding(.horizontal)
    }
}

struct RoleMatchedView: View {
    let roles: [Role]
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedRoleId: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // Title
                VStack(spacing: Theme.spacing.medium) {
                    Text("We found roles that match your description")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("Select the role that best describes your position")
                        .font(.subheadline)
                        .foregroundColor(.theme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.spacing.large)
                
                // Role Cards
                VStack(spacing: Theme.spacing.medium) {
                    ForEach(Array(roles.enumerated()), id: \.element.id) { index, role in
                        RoleCard(
                            role: role,
                            isTopMatch: index == 0,
                            isSelected: selectedRoleId == role.id,
                            onTap: {
                                selectedRoleId = role.id
                            }
                        )
                    }
                }
                
                // "None of these are my role" option
                Button(action: {
                    selectedRoleId = "none"
                }) {
                    HStack {
                        Image(systemName: selectedRoleId == "none" ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedRoleId == "none" ? .theme.accent : .theme.tertiaryText)
                        
                        Text("None of these are my role")
                            .foregroundColor(.theme.primaryText)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.theme.surface)
                    .cornerRadius(Theme.cornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                            .stroke(
                                selectedRoleId == "none" ? Color.theme.accent : Color.theme.divider,
                                lineWidth: selectedRoleId == "none" ? 2 : 1
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Continue Button
                Button(action: {
                    if selectedRoleId == "none" {
                        viewModel.selectNoMatch()
                    } else if let selectedId = selectedRoleId,
                              let selectedRole = roles.first(where: { $0.id == selectedId }) {
                        viewModel.selectRole(selectedRole)
                    }
                }) {
                    Text("Continue")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedRoleId == nil)
                .padding(.vertical, Theme.spacing.large)
            }
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
    }
}

struct RoleCard: View {
    let role: Role
    let isTopMatch: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.spacing.small) {
                        HStack {
                            Text(role.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.primaryText)
                            
                            if isTopMatch {
                                Text("BEST MATCH")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, Theme.spacing.small)
                                    .padding(.vertical, 4)
                                    .background(Color.theme.success)
                                    .cornerRadius(Theme.cornerRadius.small)
                            }
                        }
                        
                        if let confidence = role.confidence {
                            HStack(spacing: Theme.spacing.small) {
                                Text("\(Int(confidence * 100))% match")
                                    .font(.caption)
                                    .foregroundColor(.theme.success)
                                
                                // Confidence bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.theme.divider)
                                            .frame(height: 4)
                                            .cornerRadius(2)
                                        
                                        Rectangle()
                                            .fill(Color.theme.success)
                                            .frame(width: geometry.size.width * confidence, height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .frame(width: 60, height: 4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .theme.accent : .theme.tertiaryText)
                        .font(.title2)
                }
                
                Text(role.description)
                    .font(.subheadline)
                    .foregroundColor(.theme.secondaryText)
                    .lineLimit(3)
                
                if !role.commonTasks.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacing.small) {
                        Text("Common tasks:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.theme.tertiaryText)
                        
                        ForEach(role.commonTasks.prefix(2), id: \.self) { task in
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
            .background(isTopMatch ? Color.theme.success.opacity(0.05) : Color.theme.surface)
            .cornerRadius(Theme.cornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                    .stroke(
                        isSelected ? Color.theme.accent : (isTopMatch ? Color.theme.success.opacity(0.3) : Color.theme.divider),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RoleNotMatchedView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Spacer()
            
            // Info Icon
            Image(systemName: "info.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.theme.warning)
            
            // Title
            Text("We couldn't find matching roles")
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
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.selectNoMatch()
            }) {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
    }
}