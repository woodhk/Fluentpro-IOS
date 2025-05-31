//
//  Phase3CourseSelectionView.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import SwiftUI

struct Phase3CourseSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        if viewModel.showCompletionScreen {
            CompletionView(viewModel: viewModel)
        } else if viewModel.onboardingData.availableCourses.isEmpty {
            NoCoursesView(viewModel: viewModel)
        } else {
            CourseListView(viewModel: viewModel)
        }
    }
}

struct CourseListView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // Header
            VStack(spacing: Theme.spacing.small) {
                Text("Perfect courses for you!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Based on your needs, we recommend these courses")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.spacing.xxxLarge)
            
            // Course Cards
            ScrollView {
                VStack(spacing: Theme.spacing.medium) {
                    ForEach(viewModel.onboardingData.availableCourses) { course in
                        CourseCard(course: course) {
                            viewModel.selectCourse(course)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CourseCard: View {
    let course: Course
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: Theme.spacing.xxSmall) {
                        Text(course.name)
                            .font(.headline)
                            .foregroundColor(.theme.primaryText)
                        
                        HStack(spacing: Theme.spacing.small) {
                            Label(course.level, systemImage: "chart.bar.fill")
                                .font(.caption)
                            
                            Label(course.estimatedDuration, systemImage: "clock")
                                .font(.caption)
                        }
                        .foregroundColor(.theme.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Rating
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", course.effectiveness.rating))
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                        
                        Text("Effectiveness")
                            .font(.caption2)
                            .foregroundColor(.theme.tertiaryText)
                    }
                }
                
                // Description
                Text(course.description)
                    .font(.subheadline)
                    .foregroundColor(.theme.secondaryText)
                    .lineLimit(2)
                
                // Key Skills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.spacing.small) {
                        ForEach(course.effectiveness.targetSkills, id: \.self) { skill in
                            Text(skill)
                                .font(.caption)
                                .padding(.horizontal, Theme.spacing.small)
                                .padding(.vertical, Theme.spacing.xxSmall)
                                .background(Color.theme.primary.opacity(0.1))
                                .foregroundColor(.theme.primary)
                                .cornerRadius(Theme.cornerRadius.small)
                        }
                    }
                }
                
                // Lessons Count
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                    Text("\(course.lessons.count) lessons")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("Select Course")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.theme.primary)
                }
                .foregroundColor(.theme.secondaryText)
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoCoursesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Spacer()
            
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.theme.primary)
            
            // Message
            VStack(spacing: Theme.spacing.medium) {
                Text("Creating your personalized courses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("No matching courses found. Don't worry! Our experts are currently creating personalized courses just for you.")
                    .font(.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: Theme.spacing.xxSmall) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("You'll receive a notification once they're ready")
                        .font(.caption)
                }
                .foregroundColor(.theme.tertiaryText)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.acknowledgeNoCourses()
            }) {
                Text("Complete Onboarding")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, Theme.spacing.xxxLarge)
        }
    }
}

struct CompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: Theme.spacing.large) {
                Spacer()
                
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.theme.success)
                    .scaleEffect(showConfetti ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)
                
                // Message
                VStack(spacing: Theme.spacing.medium) {
                    Text("Onboarding Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("You're all set to begin your business English journey")
                        .font(.body)
                        .foregroundColor(.theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Tap to Continue
                VStack(spacing: Theme.spacing.small) {
                    Image(systemName: "hand.tap.fill")
                        .font(.title2)
                        .foregroundColor(.theme.tertiaryText)
                    
                    Text("Tap anywhere to continue")
                        .font(.subheadline)
                        .foregroundColor(.theme.tertiaryText)
                }
                .padding(.bottom, Theme.spacing.xxxLarge)
                .opacity(showConfetti ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5).delay(1.0), value: showConfetti)
            }
            
            // Confetti
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                showConfetti = true
            }
        }
        .onTapGesture {
            viewModel.finishOnboarding()
        }
    }
}

// Simple Confetti Animation
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            createConfetti()
        }
    }
    
    private func createConfetti() {
        for i in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double(i) * 0.02
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let delay: Double
    let color: Color = [Color.theme.primary, Color.theme.success, Color.yellow, Color.orange, Color.pink].randomElement()!
    let size: CGFloat = CGFloat.random(in: 8...15)
    let shape: String = ["circle", "square", "triangle"].randomElement()!
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var y: CGFloat = -100
    @State private var rotation = 0.0
    
    var body: some View {
        Group {
            if piece.shape == "circle" {
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            } else if piece.shape == "square" {
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            } else {
                Triangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            }
        }
        .position(x: piece.x, y: y)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(
                .linear(duration: 3.0)
                .delay(piece.delay)
            ) {
                y = UIScreen.main.bounds.height + 100
                rotation = 720
            }
        }
    }
}

// Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}