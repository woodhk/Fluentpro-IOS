//
//  OnboardingModelsTests.swift
//  FluentproTests
//
//  Created on 31/05/2025.
//

import XCTest
@testable import Fluentpro

final class OnboardingModelsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("🧪 OnboardingModelsTests: Starting test setup")
    }
    
    override func tearDown() {
        print("🧪 OnboardingModelsTests: Test teardown complete\n")
        super.tearDown()
    }
    
    // MARK: - OnboardingPhase Tests
    
    func testOnboardingPhaseValues() {
        print("📋 Testing OnboardingPhase enum values...")
        print("   - Expecting OnboardingPhase.basicInfo.rawValue = 'basicInfo'")
        print("   - Expecting OnboardingPhase.aiConversation.rawValue = 'aiConversation'")
        print("   - Expecting OnboardingPhase.courseSelection.rawValue = 'courseSelection'")
        print("   - Expecting OnboardingPhase.completed.rawValue = 'completed'")
        
        XCTAssertEqual(OnboardingPhase.basicInfo.rawValue, "basicInfo")
        XCTAssertEqual(OnboardingPhase.aiConversation.rawValue, "aiConversation")
        XCTAssertEqual(OnboardingPhase.courseSelection.rawValue, "courseSelection")
        XCTAssertEqual(OnboardingPhase.completed.rawValue, "completed")
        
        print("   ✅ OnboardingPhase test completed")
    }
    
    // MARK: - OnboardingUserProfile Tests
    
    func testOnboardingUserProfileInitialization() {
        print("📋 Testing OnboardingUserProfile initialization...")
        
        let profile = OnboardingUserProfile(
            nativeLanguage: "Spanish",
            industry: "Technology",
            role: "Software Developer",
            roleDescription: "I develop iOS applications"
        )
        
        print("   - Created profile with:")
        print("     • nativeLanguage: Spanish")
        print("     • industry: Technology")
        print("     • role: Software Developer")
        print("     • roleDescription: I develop iOS applications")
        
        XCTAssertEqual(profile.nativeLanguage, "Spanish")
        XCTAssertEqual(profile.industry, "Technology")
        XCTAssertEqual(profile.role, "Software Developer")
        XCTAssertEqual(profile.roleDescription, "I develop iOS applications")
        
        print("   ✅ OnboardingUserProfile initialization test completed")
    }
    
    func testOnboardingUserProfileEncoding() throws {
        print("📋 Testing OnboardingUserProfile JSON encoding...")
        
        let profile = OnboardingUserProfile(
            nativeLanguage: "French",
            industry: "Healthcare",
            role: "Nurse",
            roleDescription: "Emergency room nurse"
        )
        
        print("   - Encoding profile to JSON")
        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        print("   - Checking JSON keys use snake_case:")
        print("     • Expecting 'native_language' = 'French'")
        print("     • Expecting 'industry' = 'Healthcare'")
        print("     • Expecting 'role' = 'Nurse'")
        print("     • Expecting 'role_description' = 'Emergency room nurse'")
        
        XCTAssertEqual(json["native_language"] as? String, "French")
        XCTAssertEqual(json["industry"] as? String, "Healthcare")
        XCTAssertEqual(json["role"] as? String, "Nurse")
        XCTAssertEqual(json["role_description"] as? String, "Emergency room nurse")
        
        print("   ✅ OnboardingUserProfile encoding test completed")
    }
    
    func testOnboardingUserProfileDecoding() throws {
        let json = """
        {
            "native_language": "German",
            "industry": "Finance",
            "role": "Financial Analyst",
            "role_description": "I analyze market trends"
        }
        """
        
        let decoder = JSONDecoder()
        let profile = try decoder.decode(OnboardingUserProfile.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(profile.nativeLanguage, "German")
        XCTAssertEqual(profile.industry, "Finance")
        XCTAssertEqual(profile.role, "Financial Analyst")
        XCTAssertEqual(profile.roleDescription, "I analyze market trends")
    }
    
    // MARK: - RoleSuggestion Tests
    
    func testRoleSuggestionInitialization() {
        print("📋 Testing RoleSuggestion initialization...")
        
        let suggestion = RoleSuggestion(
            suggestedRole: "Senior Software Engineer",
            description: "Leads development teams and architects solutions",
            matchScore: 0.95
        )
        
        print("   - Created suggestion with:")
        print("     • suggestedRole: Senior Software Engineer")
        print("     • description: Leads development teams and architects solutions")
        print("     • matchScore: 0.95")
        
        XCTAssertEqual(suggestion.suggestedRole, "Senior Software Engineer")
        XCTAssertEqual(suggestion.description, "Leads development teams and architects solutions")
        XCTAssertEqual(suggestion.matchScore, 0.95)
        
        print("   ✅ RoleSuggestion initialization test completed")
    }
    
    func testRoleSuggestionDecoding() throws {
        let json = """
        {
            "suggested_role": "Product Manager",
            "description": "Manages product lifecycle",
            "match_score": 0.87
        }
        """
        
        let decoder = JSONDecoder()
        let suggestion = try decoder.decode(RoleSuggestion.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(suggestion.suggestedRole, "Product Manager")
        XCTAssertEqual(suggestion.description, "Manages product lifecycle")
        XCTAssertEqual(suggestion.matchScore, 0.87)
    }
    
    // MARK: - AIConversationMessage Tests
    
    func testAIConversationMessageInitialization() {
        let userMessage = AIConversationMessage(
            id: "1",
            role: .user,
            content: "I need to improve my presentation skills",
            timestamp: Date()
        )
        
        let aiMessage = AIConversationMessage(
            id: "2",
            role: .assistant,
            content: "I understand. Can you tell me more about the types of presentations you give?",
            timestamp: Date()
        )
        
        XCTAssertEqual(userMessage.role, .user)
        XCTAssertEqual(userMessage.content, "I need to improve my presentation skills")
        XCTAssertEqual(aiMessage.role, .assistant)
        XCTAssertEqual(aiMessage.content, "I understand. Can you tell me more about the types of presentations you give?")
    }
    
    // MARK: - Course Tests
    
    func testCourseInitialization() {
        print("📋 Testing Course initialization...")
        
        let course = Course(
            id: "course-123",
            title: "Business English for Tech Professionals",
            description: "Master technical vocabulary and communication",
            duration: "8 weeks",
            level: "Intermediate",
            topics: ["Technical Writing", "Meetings", "Presentations"],
            isCustom: false
        )
        
        print("   - Created course with:")
        print("     • id: course-123")
        print("     • title: Business English for Tech Professionals")
        print("     • duration: 8 weeks")
        print("     • level: Intermediate")
        print("     • topics count: 3")
        print("     • isCustom: false")
        
        XCTAssertEqual(course.id, "course-123")
        XCTAssertEqual(course.title, "Business English for Tech Professionals")
        XCTAssertEqual(course.duration, "8 weeks")
        XCTAssertEqual(course.level, "Intermediate")
        XCTAssertEqual(course.topics.count, 3)
        XCTAssertFalse(course.isCustom)
        
        print("   ✅ Course initialization test completed")
    }
    
    func testCourseDecoding() throws {
        let json = """
        {
            "id": "custom-456",
            "title": "Healthcare Communication",
            "description": "Patient interaction and medical terminology",
            "duration": "6 weeks",
            "level": "Advanced",
            "topics": ["Patient Care", "Medical Terms"],
            "is_custom": true
        }
        """
        
        let decoder = JSONDecoder()
        let course = try decoder.decode(Course.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(course.id, "custom-456")
        XCTAssertEqual(course.title, "Healthcare Communication")
        XCTAssertEqual(course.level, "Advanced")
        XCTAssertTrue(course.isCustom)
        XCTAssertEqual(course.topics.count, 2)
    }
    
    // MARK: - API Request/Response Tests
    
    func testSubmitProfileRequest() throws {
        let profile = OnboardingUserProfile(
            nativeLanguage: "Spanish",
            industry: "Technology",
            role: "Developer",
            roleDescription: "Mobile app development"
        )
        
        let request = SubmitProfileRequest(profile: profile)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertNotNil(json["profile"])
        let profileJson = json["profile"] as! [String: Any]
        XCTAssertEqual(profileJson["native_language"] as? String, "Spanish")
    }
    
    func testRoleMatchResponse() throws {
        let json = """
        {
            "success": true,
            "suggestion": {
                "suggested_role": "iOS Developer",
                "description": "Develops native iOS applications",
                "match_score": 0.92
            },
            "message": "Role suggestion found"
        }
        """
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(RoleMatchResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(response.success)
        XCTAssertNotNil(response.suggestion)
        XCTAssertEqual(response.suggestion?.suggestedRole, "iOS Developer")
        XCTAssertEqual(response.message, "Role suggestion found")
    }
    
    func testRoleMatchResponseNoSuggestion() throws {
        let json = """
        {
            "success": true,
            "suggestion": null,
            "message": "No matching role found, custom course will be created"
        }
        """
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(RoleMatchResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(response.success)
        XCTAssertNil(response.suggestion)
        XCTAssertEqual(response.message, "No matching role found, custom course will be created")
    }
    
    func testAIConversationRequest() throws {
        let request = AIConversationRequest(
            message: "I need help with email writing",
            conversationId: "conv-123"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["message"] as? String, "I need help with email writing")
        XCTAssertEqual(json["conversation_id"] as? String, "conv-123")
    }
    
    func testAIConversationResponse() throws {
        let json = """
        {
            "success": true,
            "reply": "I can help you improve your email writing. What types of emails do you typically write?",
            "conversation_complete": false,
            "conversation_id": "conv-123"
        }
        """
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(AIConversationResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.reply, "I can help you improve your email writing. What types of emails do you typically write?")
        XCTAssertFalse(response.conversationComplete)
        XCTAssertEqual(response.conversationId, "conv-123")
    }
    
    func testCoursesResponse() throws {
        let json = """
        {
            "success": true,
            "courses": [
                {
                    "id": "course-1",
                    "title": "Business English Essentials",
                    "description": "Core business communication skills",
                    "duration": "4 weeks",
                    "level": "Beginner",
                    "topics": ["Emails", "Meetings"],
                    "is_custom": false
                }
            ],
            "custom_courses_generating": true,
            "message": "1 course available, custom courses being generated"
        }
        """
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(CoursesResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.courses.count, 1)
        XCTAssertTrue(response.customCoursesGenerating)
        XCTAssertEqual(response.courses[0].title, "Business English Essentials")
    }
    
    func testCompleteOnboardingResponse() throws {
        let json = """
        {
            "success": true,
            "message": "Onboarding completed successfully"
        }
        """
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(CompleteOnboardingResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Onboarding completed successfully")
    }
}