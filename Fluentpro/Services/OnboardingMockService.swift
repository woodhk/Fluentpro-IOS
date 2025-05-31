//
//  OnboardingMockService.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import Foundation

// MARK: - Mock Services for Onboarding
@MainActor
class OnboardingMockService {
    static let shared = OnboardingMockService()
    
    private init() {}
    
    // MARK: - Mock Data
    private let mockRoles: [Role] = [
        Role(
            title: "Software Engineer",
            description: "Develops and maintains software applications, collaborates with cross-functional teams",
            industry: "Technology",
            commonTasks: ["Code reviews", "Technical documentation", "Team meetings", "Client presentations"]
        ),
        Role(
            title: "Product Manager",
            description: "Manages product lifecycle, coordinates with stakeholders, defines product strategy",
            industry: "Technology",
            commonTasks: ["Stakeholder meetings", "Product presentations", "Requirements documentation", "Team coordination"]
        ),
        Role(
            title: "Financial Analyst",
            description: "Analyzes financial data, prepares reports, provides investment recommendations",
            industry: "Finance",
            commonTasks: ["Financial reports", "Client presentations", "Data analysis", "Investment meetings"]
        ),
        Role(
            title: "Sales Representative",
            description: "Manages client relationships, negotiates deals, presents products to customers",
            industry: "Retail",
            commonTasks: ["Client calls", "Sales presentations", "Negotiation", "Email communication"]
        ),
        Role(
            title: "HR Manager",
            description: "Manages human resources, handles recruitment, develops company policies",
            industry: "Any",
            commonTasks: ["Employee interviews", "Policy documentation", "Team meetings", "Conflict resolution"]
        ),
        Role(
            title: "Marketing Specialist",
            description: "Creates marketing campaigns, analyzes market trends, manages brand communication",
            industry: "Marketing & Advertising",
            commonTasks: ["Campaign presentations", "Client meetings", "Content creation", "Team collaboration"]
        )
    ]
    
    private let mockCourses: [Course] = [
        Course(
            id: "course-1",
            name: "Business Email Mastery",
            description: "Master professional email communication for international business contexts",
            effectiveness: Course.CourseEffectiveness(
                rating: 4.8,
                improvementAreas: ["Email structure", "Professional tone", "Cultural awareness"],
                targetSkills: ["Written communication", "Formal language", "Email etiquette"]
            ),
            functionalLanguage: ["Formal greetings", "Request phrases", "Closing statements"],
            lessons: [
                Lesson(
                    id: "lesson-1-1",
                    name: "Email Structure and Format",
                    description: "Learn the standard structure of professional business emails",
                    keyLanguage: ["Dear Mr./Ms.", "I am writing to...", "Please find attached"],
                    summary: "Master the essential components of professional email structure",
                    scenarios: [
                        Scenario(
                            id: "scenario-1-1-1",
                            title: "Initial Client Contact",
                            context: "You need to reach out to a potential client for the first time",
                            objective: "Write a professional introductory email",
                            dialogueExample: "Dear Mr. Johnson, I hope this email finds you well...",
                            keyPhrases: ["I hope this email finds you well", "I would like to introduce", "Looking forward to hearing from you"]
                        )
                    ],
                    orderIndex: 1
                )
            ],
            estimatedDuration: "2 weeks",
            level: "Intermediate"
        ),
        Course(
            id: "course-2",
            name: "Meeting Excellence",
            description: "Develop skills for leading and participating in business meetings effectively",
            effectiveness: Course.CourseEffectiveness(
                rating: 4.9,
                improvementAreas: ["Meeting leadership", "Active participation", "Summarizing"],
                targetSkills: ["Spoken communication", "Presentation", "Active listening"]
            ),
            functionalLanguage: ["Opening meetings", "Giving opinions", "Summarizing points"],
            lessons: [
                Lesson(
                    id: "lesson-2-1",
                    name: "Opening and Leading Meetings",
                    description: "Learn to confidently open and lead business meetings",
                    keyLanguage: ["Let's get started", "The purpose of today's meeting", "Moving on to the next point"],
                    summary: "Master meeting leadership vocabulary and techniques",
                    scenarios: [
                        Scenario(
                            id: "scenario-2-1-1",
                            title: "Project Kickoff Meeting",
                            context: "You're leading the first meeting for a new project",
                            objective: "Open the meeting and set clear objectives",
                            dialogueExample: "Good morning everyone. Let's get started with our project kickoff...",
                            keyPhrases: ["Let's get started", "Our objectives today", "Any questions before we move on?"]
                        )
                    ],
                    orderIndex: 1
                )
            ],
            estimatedDuration: "3 weeks",
            level: "Intermediate"
        ),
        Course(
            id: "course-3",
            name: "Client Communication Mastery",
            description: "Perfect your client-facing communication skills for building strong relationships",
            effectiveness: Course.CourseEffectiveness(
                rating: 4.7,
                improvementAreas: ["Relationship building", "Negotiation", "Problem resolution"],
                targetSkills: ["Client relations", "Persuasion", "Conflict resolution"]
            ),
            functionalLanguage: ["Building rapport", "Addressing concerns", "Closing deals"],
            lessons: [
                Lesson(
                    id: "lesson-3-1",
                    name: "Building Client Rapport",
                    description: "Develop skills for creating strong client relationships",
                    keyLanguage: ["It's a pleasure to meet you", "I understand your concern", "Let me clarify"],
                    summary: "Learn to build trust and rapport with clients",
                    scenarios: [
                        Scenario(
                            id: "scenario-3-1-1",
                            title: "First Client Meeting",
                            context: "Meeting a new client for the first time",
                            objective: "Establish rapport and understand client needs",
                            dialogueExample: "It's a pleasure to meet you. I've been looking forward to discussing...",
                            keyPhrases: ["Pleasure to meet you", "Tell me about your business", "How can we help you achieve"]
                        )
                    ],
                    orderIndex: 1
                )
            ],
            estimatedDuration: "4 weeks",
            level: "Advanced"
        )
    ]
    
    // MARK: - Role Matching
    func matchRole(title: String, description: String, industry: String) async throws -> RoleMatchResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Simple matching logic
        let lowercaseTitle = title.lowercased()
        let matchedRole = mockRoles.first { role in
            role.title.lowercased().contains(lowercaseTitle) ||
            lowercaseTitle.contains(role.title.lowercased()) ||
            role.industry == industry
        }
        
        if let role = matchedRole {
            return RoleMatchResponse(
                matched: true,
                role: role,
                confidence: 0.85
            )
        } else {
            return RoleMatchResponse(
                matched: false,
                role: nil,
                confidence: nil
            )
        }
    }
    
    // MARK: - Course Recommendation
    func recommendCourses(for roleId: String?, industry: String, needs: [String]) async throws -> CourseRecommendationResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // For demo, return different responses based on role
        if roleId != nil {
            // Existing role - return some courses
            return CourseRecommendationResponse(
                courses: mockCourses,
                customCoursesBeingCreated: false,
                estimatedCreationTime: nil
            )
        } else {
            // New role - simulate course creation
            return CourseRecommendationResponse(
                courses: [],
                customCoursesBeingCreated: true,
                estimatedCreationTime: "24-48 hours"
            )
        }
    }
    
    // MARK: - AI Conversation
    func getAIResponse(for messages: [AIConversationMessage], industry: Industry, role: String) async throws -> String {
        // Simulate thinking delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let messageCount = messages.filter { !$0.isUser }.count
        
        // Generate contextual responses based on conversation stage
        switch messageCount {
        case 0:
            return "Hello! I'm here to understand your English communication needs better. Can you tell me about your typical workday and the types of interactions you have with colleagues or clients?"
            
        case 1:
            return "That's really helpful! Now, regarding \(industry.rawValue), what are the most challenging communication situations you face? For example, are there specific meetings, presentations, or documents you work with?"
            
        case 2:
            return "I see. As a \(role), do you often need to communicate with international teams or clients? What language barriers do you encounter most frequently?"
            
        case 3:
            return "Thank you for sharing that. One more question - what specific business English skills would help you feel more confident in your role? For instance, negotiation, technical writing, or presentation skills?"
            
        case 4:
            return "Perfect! Based on what you've told me, I can see you would benefit from focused training in business communication, especially around \(industry.rawValue)-specific terminology and professional interactions. Let me prepare some course recommendations for you."
            
        default:
            return "Thank you for all this valuable information. I have a clear picture of your needs now. Let's move forward to find the perfect courses for you!"
        }
    }
}

// MARK: - AI Conversation Service
@MainActor
class AIConversationService {
    private let mockService = OnboardingMockService.shared
    
    func processUserMessage(_ message: String, context: OnboardingData) async throws -> String {
        return try await mockService.getAIResponse(
            for: context.conversationMessages,
            industry: context.industry ?? .technology,
            role: context.roleTitle
        )
    }
    
    func extractNeeds(from messages: [AIConversationMessage]) -> [String] {
        // Mock extraction of user needs from conversation
        return [
            "Professional email writing",
            "Meeting participation and leadership",
            "Client presentation skills",
            "Cross-cultural communication",
            "Industry-specific terminology"
        ]
    }
    
    func shouldShowContinueButton(messageCount: Int) -> Bool {
        return messageCount >= 8 // After 4 exchanges (4 user + 4 AI)
    }
}