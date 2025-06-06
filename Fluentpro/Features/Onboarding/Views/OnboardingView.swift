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
                VStack {
                        // Progress Bar (only show after welcome screens)
                        if viewModel.currentPhase.rawValue >= OnboardingViewModel.OnboardingPhase.basicInfo.rawValue {
                            OnboardingProgressBar(
                                progress: viewModel.screenProgress,
                                currentPhase: viewModel.currentPhaseLabel
                            )
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        
                        // Phase Content
                        Group {
                            switch viewModel.currentPhase {
                            case .welcome:
                                WelcomeView(viewModel: viewModel)
                            case .intro:
                                IntroView(viewModel: viewModel)
                            case .basicInfo:
                                Phase1BasicInfoView(viewModel: viewModel)
                            case .phase1Complete:
                                Phase1CompleteView(viewModel: viewModel)
                            case .conversationPartners:
                                ConversationPartnersView(viewModel: viewModel)
                            case .conversationSituations:
                                ConversationSituationsView(viewModel: viewModel)
                            case .phase2Complete:
                                Phase2CompleteView(viewModel: viewModel)
                            case .onboardingComplete:
                                OnboardingCompleteView(viewModel: viewModel)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPhase)
                }
            }
            .navigationBarHidden(true)
            .loadingOverlay(viewModel.isLoading)
            .onChange(of: viewModel.isOnboardingComplete) { oldValue, completed in
                if completed {
                    // Navigation handled by viewModel
                }
            }
        }
    }
}

// Progress Bar Component
struct OnboardingProgressBar: View {
    let progress: Double
    let currentPhase: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.small) {
            HStack {
                Text("Progress: \(currentPhase)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.theme.secondaryText)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.theme.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.theme.tertiaryBackground)
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.theme.primary)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 12)
        }
    }
}


#Preview {
    OnboardingView()
        .environmentObject(NavigationCoordinator.shared)
}