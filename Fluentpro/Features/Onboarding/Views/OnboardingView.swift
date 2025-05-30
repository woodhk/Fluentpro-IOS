import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack {
                    // Skip Button
                    HStack {
                        Spacer()
                        Button(action: {
                            navigationCoordinator.navigateToHome()
                        }) {
                            Text("Skip")
                                .font(.body)
                                .foregroundColor(.theme.secondaryText)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Content
                    TabView(selection: $currentPage) {
                        // First Onboarding Screen
                        VStack(spacing: 32) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "#234BFF"))
                            
                            VStack(spacing: 16) {
                                Text("First Onboarding Screen")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.theme.primaryText)
                                    .multilineTextAlignment(.center)
                                
                                Text("Welcome to Fluentpro! Let's get you started on your journey.")
                                    .font(.body)
                                    .foregroundColor(.theme.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .tag(0)
                        
                        // Second Onboarding Screen
                        VStack(spacing: 32) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "#234BFF"))
                            
                            VStack(spacing: 16) {
                                Text("Learn at Your Pace")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.theme.primaryText)
                                    .multilineTextAlignment(.center)
                                
                                Text("Practice daily with personalized lessons tailored to your learning style.")
                                    .font(.body)
                                    .foregroundColor(.theme.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .tag(1)
                        
                        // Third Onboarding Screen
                        VStack(spacing: 32) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "#234BFF"))
                            
                            VStack(spacing: 16) {
                                Text("Track Your Progress")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.theme.primaryText)
                                    .multilineTextAlignment(.center)
                                
                                Text("Earn achievements and monitor your improvement over time.")
                                    .font(.body)
                                    .foregroundColor(.theme.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    Spacer()
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color(hex: "#234BFF") : Color.theme.border)
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // Continue Button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            navigationCoordinator.navigateToHome()
                        }
                    }) {
                        Text(currentPage < 2 ? "Continue" : "Get Started")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#234BFF"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(NavigationCoordinator())
}