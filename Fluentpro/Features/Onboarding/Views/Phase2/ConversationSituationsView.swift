//
//  ConversationSituationsView.swift
//  Fluentpro
//
//  Created on 03/06/2025.
//

import SwiftUI

struct ConversationSituationsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var currentPartner: ConversationPartner? {
        viewModel.currentPartnerSituations?.partner
    }
    
    var selectedCount: Int {
        viewModel.currentPartnerSituations?.situations.count ?? 0
    }
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Progress indicator for multiple partners
            if viewModel.selectedPartners.count > 1 {
                PartnerProgressIndicator(
                    totalPartners: viewModel.selectedPartners.count,
                    currentIndex: viewModel.onboardingData.currentPartnerIndex
                )
                .padding(.horizontal)
                .padding(.top, Theme.spacing.large)
            }
            
            // Title Section
            VStack(spacing: Theme.spacing.medium) {
                if let partner = currentPartner {
                    Text("When do you speak English with \(partner.rawValue.lowercased())?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("Select all situations that apply")
                        .font(.subheadline)
                        .foregroundColor(.theme.secondaryText)
                }
            }
            .padding(.horizontal)
            .padding(.top, viewModel.selectedPartners.count > 1 ? Theme.spacing.medium : Theme.spacing.xxxLarge)
            
            // Situations Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Theme.spacing.medium) {
                    ForEach(ConversationSituation.allCases) { situation in
                        SituationSelectionCard(
                            situation: situation,
                            isSelected: viewModel.currentPartnerSituations?.situations.contains(situation) ?? false,
                            onTap: {
                                viewModel.toggleSituation(situation)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Theme.spacing.large)
            }
            
            Spacer()
            
            // Selection counter
            if selectedCount > 0 {
                Text("\(selectedCount) selected")
                    .font(.caption)
                    .foregroundColor(.theme.tertiaryText)
            }
            
            // Error message if any
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.theme.error)
                    .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: {
                viewModel.continueFromSituationSelection()
            }) {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selectedCount == 0)
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
    }
}

struct SituationSelectionCard: View {
    let situation: ConversationSituation
    let isSelected: Bool
    let onTap: () -> Void
    
    var situationIcon: String {
        switch situation {
        case .interviews: return "person.bubble"
        case .conflictResolution: return "exclamationmark.bubble"
        case .phoneCalls: return "phone"
        case .oneOnOnes: return "person.2"
        case .feedbackSessions: return "bubble.left.and.bubble.right"
        case .teamDiscussions: return "person.3"
        case .negotiations: return "hands.sparkles"
        case .statusUpdates: return "chart.bar"
        case .informalChats: return "message"
        case .briefings: return "doc.text"
        case .meetings: return "calendar"
        case .presentations: return "tv"
        case .trainingSessions: return "book"
        case .clientConversations: return "person.crop.circle"
        case .videoConferences: return "video"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.spacing.small) {
                // Icon
                Image(systemName: situationIcon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .theme.accent : .theme.tertiaryText)
                    .frame(height: 35)
                
                Text(situation.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(Theme.spacing.medium)
            .background(isSelected ? Color.theme.accent.opacity(0.1) : Color.theme.surface)
            .cornerRadius(Theme.cornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius.medium)
                    .stroke(isSelected ? Color.theme.accent : Color.theme.divider, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PartnerProgressIndicator: View {
    let totalPartners: Int
    let currentIndex: Int
    
    var body: some View {
        VStack(spacing: Theme.spacing.small) {
            // Progress dots
            HStack(spacing: Theme.spacing.small) {
                ForEach(0..<totalPartners, id: \.self) { index in
                    Circle()
                        .fill(index <= currentIndex ? Color.theme.accent : Color.theme.divider)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentIndex)
                }
            }
            
            Text("Partner \(currentIndex + 1) of \(totalPartners)")
                .font(.caption)
                .foregroundColor(.theme.secondaryText)
        }
    }
}