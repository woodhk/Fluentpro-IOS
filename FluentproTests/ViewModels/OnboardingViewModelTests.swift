//
//  OnboardingViewModelTests.swift
//  FluentproTests
//
//  Created on 31/05/2025.
//

import XCTest
import Combine
@testable import Fluentpro

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    var sut: OnboardingViewModel!
    var mockOnboardingService: MockOnboardingService!
    var mockNavigationCoordinator: MockNavigationCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        print("📦 OnboardingViewModelTests: Starting test setup")
        mockOnboardingService = MockOnboardingService()
        mockNavigationCoordinator = MockNavigationCoordinator()
        sut = OnboardingViewModel(
            onboardingService: mockOnboardingService,
            navigationCoordinator: mockNavigationCoordinator
        )
        cancellables = []
        print("   - Created OnboardingViewModel with mocks")
    }
    
    override func tearDown() {
        sut = nil
        mockOnboardingService = nil
        mockNavigationCoordinator = nil
        cancellables = nil
        print("📦 OnboardingViewModelTests: Test teardown complete\n")
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        print("📋 Testing OnboardingViewModel initial state...")
        print("   - Checking initial values:")
        print("     • currentPhase: \(sut.currentPhase) (expected: .basicInfo)")
        print("     • isLoading: \(sut.isLoading) (expected: false)")
        print("     • errorMessage: \(sut.errorMessage ?? "nil") (expected: nil)")
        print("     • userProfile: \(sut.userProfile == nil ? "nil" : "exists") (expected: nil)")
        print("     • conversationMessages count: \(sut.conversationMessages.count) (expected: 0)")
        print("     • availableCourses count: \(sut.availableCourses.count) (expected: 0)")
        
        XCTAssertEqual(sut.currentPhase, .basicInfo)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertNil(sut.userProfile)
        XCTAssertNil(sut.roleSuggestion)
        XCTAssertNil(sut.conversationId)
        XCTAssertTrue(sut.conversationMessages.isEmpty)
        XCTAssertTrue(sut.availableCourses.isEmpty)
        XCTAssertFalse(sut.customCoursesGenerating)
        XCTAssertNil(sut.selectedCourseId)
        
        print("   ✅ Initial state test completed")
    }
    
    // MARK: - Phase 1: Basic Info Tests
    
    func testSubmitBasicInfoSuccess() async {
        print("📋 Testing submitBasicInfo success flow...")
        
        // Given
        let profile = OnboardingUserProfile(
            nativeLanguage: "Spanish",
            industry: "Technology",
            role: "Developer",
            roleDescription: "iOS Developer"
        )
        print("   - Setting up mock responses")
        
        mockOnboardingService.submitProfileResponse = SubmitProfileResponse(
            success: true,
            message: "Profile submitted"
        )
        
        mockOnboardingService.roleMatchResponse = RoleMatchResponse(
            success: true,
            suggestion: RoleSuggestion(
                suggestedRole: "iOS Developer",
                description: "Develops iOS applications",
                matchScore: 0.95
            ),
            message: "Match found"
        )
        
        // When
        print("   - Submitting basic info...")
        await sut.submitBasicInfo(
            nativeLanguage: "Spanish",
            industry: "Technology",
            role: "Developer",
            roleDescription: "iOS Developer"
        )
        
        // Then
        print("   - Verifying results:")
        print("     • userProfile exists: \(sut.userProfile != nil)")
        print("     • native language: \(sut.userProfile?.nativeLanguage ?? "nil")")
        print("     • role suggestion exists: \(sut.roleSuggestion != nil)")
        print("     • suggested role: \(sut.roleSuggestion?.suggestedRole ?? "nil")")
        print("     • error message: \(sut.errorMessage ?? "nil")")
        
        XCTAssertNotNil(sut.userProfile)
        XCTAssertEqual(sut.userProfile?.nativeLanguage, "Spanish")
        XCTAssertNotNil(sut.roleSuggestion)
        XCTAssertEqual(sut.roleSuggestion?.suggestedRole, "iOS Developer")
        XCTAssertNil(sut.errorMessage)
        
        print("   ✅ submitBasicInfo success test completed")
    }
    
    func testSubmitBasicInfoNoRoleMatch() async {
        // Given
        mockOnboardingService.submitProfileResponse = SubmitProfileResponse(
            success: true,
            message: "Profile submitted"
        )
        
        mockOnboardingService.roleMatchResponse = RoleMatchResponse(
            success: true,
            suggestion: nil,
            message: "No match found"
        )
        
        // When
        await sut.submitBasicInfo(
            nativeLanguage: "Japanese",
            industry: "Other",
            role: "Unique",
            roleDescription: "Very specific role"
        )
        
        // Then
        XCTAssertNil(sut.roleSuggestion)
        XCTAssertEqual(sut.currentPhase, .aiConversation)
    }
    
    func testSubmitBasicInfoError() async {
        // Given
        mockOnboardingService.shouldThrowError = true
        mockOnboardingService.errorToThrow = NetworkError.networkError(NSError(domain: "", code: -1))
        
        // When
        await sut.submitBasicInfo(
            nativeLanguage: "English",
            industry: "Finance",
            role: "Analyst",
            roleDescription: "Financial analysis"
        )
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.currentPhase, .basicInfo)
    }
    
    // MARK: - Role Confirmation Tests
    
    func testConfirmRoleSuggestionAccepted() async {
        // Given
        sut.roleSuggestion = RoleSuggestion(
            suggestedRole: "Software Engineer",
            description: "Develops software",
            matchScore: 0.9
        )
        
        // When
        await sut.confirmRoleSuggestion(accepted: true)
        
        // Then
        XCTAssertEqual(sut.currentPhase, .aiConversation)
    }
    
    func testConfirmRoleSuggestionRejected() async {
        // Given
        sut.roleSuggestion = RoleSuggestion(
            suggestedRole: "Wrong Role",
            description: "Wrong description",
            matchScore: 0.5
        )
        
        // When
        await sut.confirmRoleSuggestion(accepted: false)
        
        // Then
        XCTAssertEqual(sut.currentPhase, .aiConversation)
        XCTAssertNil(sut.roleSuggestion)
    }
    
    // MARK: - Phase 2: AI Conversation Tests
    
    func testSendMessageFirstMessage() async {
        print("📋 Testing sendMessage for AI conversation...")
        
        // Given
        mockOnboardingService.aiConversationResponse = AIConversationResponse(
            success: true,
            reply: "Hello! How can I help you?",
            conversationComplete: false,
            conversationId: "conv-123"
        )
        print("   - Set up AI response mock")
        
        // When
        print("   - Sending user message: 'I need help with presentations'")
        await sut.sendMessage("I need help with presentations")
        
        // Then
        print("   - Verifying conversation state:")
        print("     • message count: \(sut.conversationMessages.count) (expected: 2)")
        print("     • message 1 role: \(sut.conversationMessages.first?.role ?? "nil") (expected: .user)")
        print("     • message 1 content: \(sut.conversationMessages.first?.content ?? "nil")")
        print("     • message 2 role: \(sut.conversationMessages.last?.role ?? "nil") (expected: .assistant)")
        print("     • conversation ID: \(sut.conversationId ?? "nil")")
        print("     • show continue button: \(sut.showContinueButton)")
        
        XCTAssertEqual(sut.conversationMessages.count, 2)
        XCTAssertEqual(sut.conversationMessages[0].role, .user)
        XCTAssertEqual(sut.conversationMessages[0].content, "I need help with presentations")
        XCTAssertEqual(sut.conversationMessages[1].role, .assistant)
        XCTAssertEqual(sut.conversationMessages[1].content, "Hello! How can I help you?")
        XCTAssertEqual(sut.conversationId, "conv-123")
        XCTAssertFalse(sut.showContinueButton)
        
        print("   ✅ sendMessage test completed")
    }
    
    func testSendMessageConversationComplete() async {
        // Given
        sut.conversationId = "conv-123"
        mockOnboardingService.aiConversationResponse = AIConversationResponse(
            success: true,
            reply: "Thank you, I have all the information I need.",
            conversationComplete: true,
            conversationId: "conv-123"
        )
        
        // When
        await sut.sendMessage("I present to executives")
        
        // Then
        XCTAssertTrue(sut.showContinueButton)
        XCTAssertEqual(sut.conversationMessages.last?.content, "Thank you, I have all the information I need.")
    }
    
    func testSendMessageError() async {
        // Given
        mockOnboardingService.shouldThrowError = true
        mockOnboardingService.errorToThrow = NetworkError.httpError(500, "Server error")
        
        let initialMessageCount = sut.conversationMessages.count
        
        // When
        await sut.sendMessage("Test message")
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.conversationMessages.count, initialMessageCount + 1) // Only user message added
    }
    
    func testContinueFromAIConversation() async {
        // Given
        sut.currentPhase = .aiConversation
        sut.showContinueButton = true
        
        mockOnboardingService.coursesResponse = CoursesResponse(
            success: true,
            courses: [
                Course(
                    id: "1",
                    title: "Business English",
                    description: "Business communication",
                    duration: "6 weeks",
                    level: "Intermediate",
                    topics: ["Email"],
                    isCustom: false
                )
            ],
            customCoursesGenerating: false,
            message: "1 course found"
        )
        
        // When
        await sut.continueFromAIConversation()
        
        // Then
        XCTAssertEqual(sut.currentPhase, .courseSelection)
        XCTAssertEqual(sut.availableCourses.count, 1)
        XCTAssertFalse(sut.customCoursesGenerating)
    }
    
    // MARK: - Phase 3: Course Selection Tests
    
    func testLoadCoursesWithMatches() async {
        // Given
        let courses = [
            Course(id: "1", title: "Course 1", description: "Desc 1", duration: "4 weeks", level: "Beginner", topics: ["Topic1"], isCustom: false),
            Course(id: "2", title: "Course 2", description: "Desc 2", duration: "6 weeks", level: "Intermediate", topics: ["Topic2"], isCustom: false)
        ]
        
        mockOnboardingService.coursesResponse = CoursesResponse(
            success: true,
            courses: courses,
            customCoursesGenerating: false,
            message: "2 courses found"
        )
        
        // When
        await sut.loadCourses()
        
        // Then
        XCTAssertEqual(sut.availableCourses.count, 2)
        XCTAssertFalse(sut.customCoursesGenerating)
        XCTAssertEqual(sut.availableCourses[0].title, "Course 1")
    }
    
    func testLoadCoursesWithCustomGeneration() async {
        // Given
        mockOnboardingService.coursesResponse = CoursesResponse(
            success: true,
            courses: [],
            customCoursesGenerating: true,
            message: "Generating custom courses"
        )
        
        // When
        await sut.loadCourses()
        
        // Then
        XCTAssertTrue(sut.availableCourses.isEmpty)
        XCTAssertTrue(sut.customCoursesGenerating)
    }
    
    func testSelectCourse() {
        // Given
        let course = Course(
            id: "course-123",
            title: "Selected Course",
            description: "Description",
            duration: "8 weeks",
            level: "Advanced",
            topics: ["Topic"],
            isCustom: false
        )
        sut.availableCourses = [course]
        
        // When
        sut.selectCourse("course-123")
        
        // Then
        XCTAssertEqual(sut.selectedCourseId, "course-123")
    }
    
    // MARK: - Complete Onboarding Tests
    
    func testCompleteOnboardingWithSelectedCourse() async {
        print("📋 Testing completeOnboarding with selected course...")
        
        // Given
        sut.selectedCourseId = "course-123"
        mockOnboardingService.completeOnboardingResponse = CompleteOnboardingResponse(
            success: true,
            message: "Onboarding completed"
        )
        print("   - Set selected course ID: course-123")
        
        // When
        print("   - Calling completeOnboarding...")
        await sut.completeOnboarding()
        
        // Then
        print("   - Verifying completion:")
        print("     • current phase: \(sut.currentPhase) (expected: .completed)")
        print("     • navigation to home called: \(mockNavigationCoordinator.navigateToHomeCalled)")
        
        XCTAssertEqual(sut.currentPhase, .completed)
        XCTAssertTrue(mockNavigationCoordinator.navigateToHomeCalled)
        
        print("   ✅ completeOnboarding test completed")
    }
    
    func testCompleteOnboardingWithoutCourse() async {
        // Given
        sut.selectedCourseId = nil
        sut.customCoursesGenerating = true
        mockOnboardingService.completeOnboardingResponse = CompleteOnboardingResponse(
            success: true,
            message: "Onboarding completed, awaiting courses"
        )
        
        // When
        await sut.completeOnboarding()
        
        // Then
        XCTAssertEqual(sut.currentPhase, .completed)
        XCTAssertTrue(mockNavigationCoordinator.navigateToHomeCalled)
    }
    
    func testCompleteOnboardingError() async {
        // Given
        mockOnboardingService.shouldThrowError = true
        mockOnboardingService.errorToThrow = NetworkError.httpError(500, "Server error")
        
        // When
        await sut.completeOnboarding()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNotEqual(sut.currentPhase, .completed)
        XCTAssertFalse(mockNavigationCoordinator.navigateToHomeCalled)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateToHome() {
        // When
        sut.navigateToHome()
        
        // Then
        XCTAssertTrue(mockNavigationCoordinator.navigateToHomeCalled)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() {
        // Given
        sut.errorMessage = "Test error"
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
}

// MARK: - Mock Services

class MockOnboardingService: OnboardingServiceProtocol {
    var submitProfileResponse: SubmitProfileResponse?
    var roleMatchResponse: RoleMatchResponse?
    var aiConversationResponse: AIConversationResponse?
    var coursesResponse: CoursesResponse?
    var completeOnboardingResponse: CompleteOnboardingResponse?
    
    var shouldThrowError = false
    var errorToThrow: Error?
    
    func submitProfile(_ profile: OnboardingUserProfile) async throws -> SubmitProfileResponse {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return submitProfileResponse ?? SubmitProfileResponse(success: false, message: "No mock response")
    }
    
    func getRoleMatch(for profile: OnboardingUserProfile) async throws -> RoleMatchResponse {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return roleMatchResponse ?? RoleMatchResponse(success: false, suggestion: nil, message: "No mock response")
    }
    
    func sendAIMessage(_ message: String, conversationId: String?) async throws -> AIConversationResponse {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return aiConversationResponse ?? AIConversationResponse(
            success: false,
            reply: "No mock response",
            conversationComplete: false,
            conversationId: "mock"
        )
    }
    
    func getCourses() async throws -> CoursesResponse {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return coursesResponse ?? CoursesResponse(
            success: false,
            courses: [],
            customCoursesGenerating: false,
            message: "No mock response"
        )
    }
    
    func completeOnboarding(selectedCourseId: String?) async throws -> CompleteOnboardingResponse {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        return completeOnboardingResponse ?? CompleteOnboardingResponse(
            success: false,
            message: "No mock response"
        )
    }
}

class MockNavigationCoordinator: NavigationCoordinator {
    var navigateToHomeCalled = false
    
    override func navigateToHome() {
        navigateToHomeCalled = true
    }
}