//
//  ConversationPartnersView.swift
//  Fluentpro
//
//  Created on 03/06/2025.
//

import SwiftUI

struct ConversationPartnersView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Title Section
            VStack(spacing: Theme.spacing.medium) {
                Text("Who do you typically speak English with at work?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(.theme.secondaryText)
            }
            .padding(.horizontal)
            .padding(.top, Theme.spacing.xxxLarge)
            
            // Partners Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Theme.spacing.medium) {
                    ForEach(ConversationPartner.allCases) { partner in
                        PartnerSelectionCard(
                            partner: partner,
                            isSelected: viewModel.selectedPartners.contains(partner),
                            onTap: {
                                viewModel.togglePartner(partner)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Theme.spacing.large)
            }
            
            Spacer()
            
            // Error message if any
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.theme.error)
                    .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: {
                viewModel.continueFromPartnerSelection()
            }) {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.selectedPartners.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
    }
}

struct PartnerSelectionCard: View {
    let partner: ConversationPartner
    let isSelected: Bool
    let onTap: () -> Void
    
    var partnerIcon: String {
        switch partner {
        case .clients: return "person.2.circle"
        case .customers: return "cart.circle"
        case .colleagues: return "person.3"
        case .suppliers: return "shippingbox"
        case .partners: return "handshake"
        case .seniorManagement: return "person.crop.circle.badge.checkmark"
        case .stakeholders: return "building.2"
        case .other: return "ellipsis.circle"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.spacing.medium) {
                // Icon with selection indicator
                ZStack(alignment: .topTrailing) {
                    Image(systemName: partnerIcon)
                        .font(.system(size: 40))
                        .foregroundColor(isSelected ? .theme.accent : .theme.tertiaryText)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.theme.accent)
                            .background(Color.theme.background.clipShape(Circle()))
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(partner.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
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