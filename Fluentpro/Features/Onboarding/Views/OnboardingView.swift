import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                // Main Content
                if viewModel.showIntermission {
                    IntermissionView()
                } else {
                    VStack {
                        // Phase Indicator
                        PhaseIndicator(currentPhase: viewModel.currentPhase)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        // Phase Content
                        Group {
                            switch viewModel.currentPhase {
                            case .basicInfo:
                                Phase1BasicInfoView(viewModel: viewModel)
                            case .aiConversation:
                                Phase2ConversationView(viewModel: viewModel)
                            case .courseSelection:
                                Phase3CourseSelectionView(viewModel: viewModel)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPhase)
                    }
                }
            }
            .navigationBarHidden(true)
            .loadingOverlay(viewModel.isLoading)
            .onChange(of: viewModel.isOnboardingComplete) { completed in
                if completed {
                    // Navigation handled by viewModel
                }
            }
        }
    }
}

// Phase Indicator Component
struct PhaseIndicator: View {
    let currentPhase: OnboardingViewModel.OnboardingPhase
    
    var body: some View {
        VStack(spacing: Theme.spacing.small) {
            Text("Phase \(currentPhase.phaseNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.theme.secondaryText)
            
            HStack(spacing: Theme.spacing.small) {
                ForEach(OnboardingViewModel.OnboardingPhase.allCases, id: \.self) { phase in
                    PhaseIndicatorDot(
                        isActive: phase.rawValue <= currentPhase.rawValue,
                        isCurrent: phase == currentPhase
                    )
                }
            }
        }
    }
}

struct PhaseIndicatorDot: View {
    let isActive: Bool
    let isCurrent: Bool
    
    var body: some View {
        Circle()
            .fill(isActive ? Color.theme.primary : Color.theme.border)
            .frame(width: isCurrent ? 12 : 8, height: isCurrent ? 12 : 8)
            .animation(.easeInOut(duration: 0.3), value: isActive)
            .animation(.easeInOut(duration: 0.3), value: isCurrent)
    }
}

// Intermission/Loading View
struct IntermissionView: View {
    @State private var loadingText = "Analyzing your needs"
    @State private var dotCount = 0
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Spacer()
            
            // Loading Animation
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .theme.primary))
                .scaleEffect(1.5)
            
            // Loading Text
            Text(loadingText + String(repeating: ".", count: dotCount))
                .font(.headline)
                .foregroundColor(.theme.primaryText)
            
            Text("Finding the perfect courses for you")
                .font(.subheadline)
                .foregroundColor(.theme.secondaryText)
            
            Spacer()
        }
        .onAppear {
            animateDots()
        }
    }
    
    private func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation {
                dotCount = (dotCount + 1) % 4
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(NavigationCoordinator.shared)
}