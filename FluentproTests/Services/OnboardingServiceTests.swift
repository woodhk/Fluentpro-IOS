//
//  OnboardingServiceTests.swift
//  FluentproTests
//
//  Created on 31/05/2025.
//

import XCTest
@testable import Fluentpro

final class OnboardingServiceTests: XCTestCase {
    var sut: OnboardingService!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        print("🧪 OnboardingServiceTests: Starting test setup")
        mockNetworkService = MockNetworkService()
        sut = OnboardingService(networkService: mockNetworkService)
        print("   - Created OnboardingService with mock network service")
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        print("🧪 OnboardingServiceTests: Test teardown complete\n")
        super.tearDown()
    }
    
    // MARK: - Submit Profile Tests
    
    func testSubmitProfileSuccess() async throws {
        print("📋 Testing submitProfile success case...")
        
        // Given
        let profile = OnboardingUserProfile(
            nativeLanguage: "Spanish",
            industry: "Technology",
            role: "Developer",
            roleDescription: "iOS Development"
        )
        print("   - Created test profile")
        
        let expectedResponse = SubmitProfileResponse(
            success: true,
            message: "Profile submitted successfully"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        print("   - Set mock response for success")
        
        // When
        print("   - Calling submitProfile...")
        let response = try await sut.submitProfile(profile)
        
        // Then
        print("   - Verifying response:")
        print("     • success: \(response.success) (expected: true)")
        print("     • message: \(response.message ?? "nil") (expected: Profile submitted successfully)")
        print("     • endpoint called: \(mockNetworkService.lastEndpoint?.rawValue ?? "nil") (expected: submitOnboardingProfile)")
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Profile submitted successfully")
        XCTAssertEqual(mockNetworkService.lastEndpoint, .submitOnboardingProfile)
        XCTAssertTrue(mockNetworkService.lastBody is SubmitProfileRequest)
        
        print("   ✅ submitProfile success test completed")
    }
    
    func testSubmitProfileFailure() async {
        // Given
        let profile = OnboardingUserProfile(
            nativeLanguage: "Spanish",
            industry: "Technology",
            role: "Developer",
            roleDescription: "iOS Development"
        )
        
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = NetworkError.httpError(400, "Invalid profile data")
        
        // When/Then
        do {
            _ = try await sut.submitProfile(profile)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Role Match Tests
    
    func testGetRoleMatchWithSuggestion() async throws {
        print("📋 Testing getRoleMatch with suggestion...")
        
        // Given
        let profile = OnboardingUserProfile(
            nativeLanguage: "English",
            industry: "Healthcare",
            role: "Nurse",
            roleDescription: "Emergency room nurse"
        )
        print("   - Created healthcare profile")
        
        let expectedResponse = RoleMatchResponse(
            success: true,
            suggestion: RoleSuggestion(
                suggestedRole: "Emergency Room Nurse",
                description: "Provides critical care in emergency settings",
                matchScore: 0.95
            ),
            message: "Role match found"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        print("   - Set mock response with role suggestion")
        
        // When
        print("   - Calling getRoleMatch...")
        let response = try await sut.getRoleMatch(for: profile)
        
        // Then
        print("   - Verifying response:")
        print("     • success: \(response.success)")
        print("     • suggestion exists: \(response.suggestion != nil)")
        print("     • suggested role: \(response.suggestion?.suggestedRole ?? "nil")")
        print("     • match score: \(response.suggestion?.matchScore ?? 0)")
        
        XCTAssertTrue(response.success)
        XCTAssertNotNil(response.suggestion)
        XCTAssertEqual(response.suggestion?.suggestedRole, "Emergency Room Nurse")
        XCTAssertEqual(response.suggestion?.matchScore, 0.95)
        
        print("   ✅ getRoleMatch with suggestion test completed")
    }
    
    func testGetRoleMatchNoSuggestion() async throws {
        // Given
        let profile = OnboardingUserProfile(
            nativeLanguage: "Japanese",
            industry: "Other",
            role: "Unique Role",
            roleDescription: "Very specific role"
        )
        
        let expectedResponse = RoleMatchResponse(
            success: true,
            suggestion: nil,
            message: "No role match found"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.getRoleMatch(for: profile)
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertNil(response.suggestion)
        XCTAssertEqual(response.message, "No role match found")
    }
    
    // MARK: - AI Conversation Tests
    
    func testSendAIMessageFirstMessage() async throws {
        print("📋 Testing sendAIMessage for first message...")
        
        // Given
        let expectedResponse = AIConversationResponse(
            success: true,
            reply: "Hello! I'd love to help you improve your English. What specific areas would you like to focus on?",
            conversationComplete: false,
            conversationId: "conv-123"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        print("   - Set mock AI response")
        
        // When
        print("   - Sending first message to AI...")
        let response = try await sut.sendAIMessage("I want to improve my English", conversationId: nil)
        
        // Then
        print("   - Verifying AI response:")
        print("     • success: \(response.success)")
        print("     • reply length: \(response.reply.count) characters")
        print("     • conversation complete: \(response.conversationComplete)")
        print("     • conversation ID: \(response.conversationId)")
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.reply, "Hello! I'd love to help you improve your English. What specific areas would you like to focus on?")
        XCTAssertFalse(response.conversationComplete)
        XCTAssertEqual(response.conversationId, "conv-123")
        
        print("   ✅ sendAIMessage first message test completed")
    }
    
    func testSendAIMessageContinuation() async throws {
        // Given
        let expectedResponse = AIConversationResponse(
            success: true,
            reply: "Great! Let me ask you a few more questions.",
            conversationComplete: false,
            conversationId: "conv-123"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.sendAIMessage("I need help with presentations", conversationId: "conv-123")
        
        // Then
        XCTAssertEqual(response.conversationId, "conv-123")
        XCTAssertFalse(response.conversationComplete)
    }
    
    func testSendAIMessageCompletion() async throws {
        // Given
        let expectedResponse = AIConversationResponse(
            success: true,
            reply: "Thank you for the information. I have enough details to recommend courses for you.",
            conversationComplete: true,
            conversationId: "conv-123"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.sendAIMessage("I present to international clients", conversationId: "conv-123")
        
        // Then
        XCTAssertTrue(response.conversationComplete)
    }
    
    // MARK: - Get Courses Tests
    
    func testGetCoursesWithMatches() async throws {
        print("📋 Testing getCourses with matching courses...")
        
        // Given
        let courses = [
            Course(
                id: "1",
                title: "Business English",
                description: "Essential business communication",
                duration: "6 weeks",
                level: "Intermediate",
                topics: ["Email", "Meetings"],
                isCustom: false
            ),
            Course(
                id: "2",
                title: "Technical English",
                description: "Technology vocabulary",
                duration: "4 weeks",
                level: "Advanced",
                topics: ["Documentation", "Presentations"],
                isCustom: false
            )
        ]
        print("   - Created 2 test courses")
        
        let expectedResponse = CoursesResponse(
            success: true,
            courses: courses,
            customCoursesGenerating: false,
            message: "2 courses found"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        print("   - Set mock response with courses")
        
        // When
        print("   - Calling getCourses...")
        let response = try await sut.getCourses()
        
        // Then
        print("   - Verifying response:")
        print("     • success: \(response.success)")
        print("     • courses count: \(response.courses.count)")
        print("     • custom courses generating: \(response.customCoursesGenerating)")
        print("     • first course title: \(response.courses.first?.title ?? "nil")")
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.courses.count, 2)
        XCTAssertFalse(response.customCoursesGenerating)
        XCTAssertEqual(response.courses[0].title, "Business English")
        
        print("   ✅ getCourses with matches test completed")
    }
    
    func testGetCoursesWithCustomGeneration() async throws {
        // Given
        let expectedResponse = CoursesResponse(
            success: true,
            courses: [],
            customCoursesGenerating: true,
            message: "Custom courses are being generated"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.getCourses()
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.courses.count, 0)
        XCTAssertTrue(response.customCoursesGenerating)
    }
    
    func testGetCoursesMixedResponse() async throws {
        // Given
        let course = Course(
            id: "1",
            title: "General Business English",
            description: "Basic business communication",
            duration: "8 weeks",
            level: "Beginner",
            topics: ["General"],
            isCustom: false
        )
        
        let expectedResponse = CoursesResponse(
            success: true,
            courses: [course],
            customCoursesGenerating: true,
            message: "1 course available, custom courses being generated"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.getCourses()
        
        // Then
        XCTAssertEqual(response.courses.count, 1)
        XCTAssertTrue(response.customCoursesGenerating)
    }
    
    // MARK: - Complete Onboarding Tests
    
    func testCompleteOnboardingSuccess() async throws {
        // Given
        let expectedResponse = CompleteOnboardingResponse(
            success: true,
            message: "Onboarding completed"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.completeOnboarding(selectedCourseId: "course-123")
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Onboarding completed")
        XCTAssertEqual(mockNetworkService.lastEndpoint, .completeOnboarding)
    }
    
    func testCompleteOnboardingWithoutCourse() async throws {
        // Given
        let expectedResponse = CompleteOnboardingResponse(
            success: true,
            message: "Onboarding completed, awaiting custom courses"
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let response = try await sut.completeOnboarding(selectedCourseId: nil)
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Onboarding completed, awaiting custom courses")
    }
}

// MARK: - Mock Network Service

class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var shouldThrowError = false
    var errorToThrow: Error?
    var lastEndpoint: APIEndpoints?
    var lastBody: Any?
    
    func get<T: Decodable>(_ endpoint: APIEndpoints, authenticated: Bool) async throws -> T {
        lastEndpoint = endpoint
        
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }
        
        return response
    }
    
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoints, body: B?, authenticated: Bool) async throws -> T {
        lastEndpoint = endpoint
        lastBody = body
        
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }
        
        return response
    }
    
    func put<T: Decodable, B: Encodable>(_ endpoint: APIEndpoints, body: B?, authenticated: Bool) async throws -> T {
        lastEndpoint = endpoint
        lastBody = body
        
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }
        
        return response
    }
    
    func delete(_ endpoint: APIEndpoints, authenticated: Bool) async throws {
        lastEndpoint = endpoint
        
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
    }
}