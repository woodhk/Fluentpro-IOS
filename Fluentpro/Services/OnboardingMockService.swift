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
        // Banking & Finance roles
        Role(
            title: "Investment Banker",
            description: "Advises clients on financial transactions, manages mergers and acquisitions, prepares financial models",
            industry: "Banking & Finance",
            commonTasks: ["Client presentations", "Financial modeling", "Deal negotiations", "Regulatory compliance"]
        ),
        Role(
            title: "Financial Analyst",
            description: "Analyzes financial data, prepares reports, provides investment recommendations",
            industry: "Banking & Finance",
            commonTasks: ["Financial reports", "Client presentations", "Data analysis", "Investment meetings"]
        ),
        Role(
            title: "Relationship Manager",
            description: "Manages client portfolios, develops banking relationships, provides financial advice",
            industry: "Banking & Finance",
            commonTasks: ["Client meetings", "Portfolio reviews", "Financial advising", "Cross-selling"]
        ),
        
        // Shipping & Logistics roles
        Role(
            title: "Logistics Coordinator",
            description: "Coordinates shipments, manages supply chain operations, liaises with carriers and customers",
            industry: "Shipping & Logistics",
            commonTasks: ["Vendor negotiations", "Shipment tracking", "Customer updates", "Problem resolution"]
        ),
        Role(
            title: "Supply Chain Manager",
            description: "Oversees supply chain operations, optimizes logistics processes, manages vendor relationships",
            industry: "Shipping & Logistics",
            commonTasks: ["Strategic planning", "Vendor meetings", "Performance reviews", "Cost negotiations"]
        ),
        Role(
            title: "Freight Forwarder",
            description: "Arranges cargo transportation, handles customs documentation, coordinates with shipping lines",
            industry: "Shipping & Logistics",
            commonTasks: ["Customs clearance", "Rate negotiations", "Client communication", "Documentation"]
        ),
        
        // Real Estate roles
        Role(
            title: "Real Estate Agent",
            description: "Shows properties to clients, negotiates deals, manages property listings",
            industry: "Real Estate",
            commonTasks: ["Property showings", "Price negotiations", "Contract discussions", "Market analysis"]
        ),
        Role(
            title: "Property Manager",
            description: "Manages rental properties, handles tenant relations, oversees maintenance",
            industry: "Real Estate",
            commonTasks: ["Tenant communication", "Vendor coordination", "Lease negotiations", "Property inspections"]
        ),
        Role(
            title: "Real Estate Developer",
            description: "Develops property projects, manages construction, secures financing",
            industry: "Real Estate",
            commonTasks: ["Investor presentations", "Contractor meetings", "Permit applications", "Stakeholder updates"]
        ),
        
        // Hotels & Hospitality roles
        Role(
            title: "Hotel Manager",
            description: "Oversees hotel operations, manages staff, ensures guest satisfaction",
            industry: "Hotels & Hospitality",
            commonTasks: ["Staff meetings", "Guest relations", "Vendor negotiations", "Performance reviews"]
        ),
        Role(
            title: "Guest Relations Manager",
            description: "Handles guest concerns, manages VIP services, ensures customer satisfaction",
            industry: "Hotels & Hospitality",
            commonTasks: ["Guest communication", "Complaint resolution", "VIP coordination", "Service training"]
        ),
        Role(
            title: "Event Coordinator",
            description: "Plans and executes events, coordinates with vendors, manages client expectations",
            industry: "Hotels & Hospitality",
            commonTasks: ["Client consultations", "Vendor coordination", "Event presentations", "Budget discussions"]
        ),
        
        // Cross-industry roles
        Role(
            title: "Sales Manager",
            description: "Leads sales team, develops sales strategies, manages client relationships",
            industry: "Any",
            commonTasks: ["Sales presentations", "Team meetings", "Client negotiations", "Performance reviews"]
        ),
        Role(
            title: "HR Manager",
            description: "Manages human resources, handles recruitment, develops company policies",
            industry: "Any",
            commonTasks: ["Employee interviews", "Policy documentation", "Team meetings", "Conflict resolution"]
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
        
        // Enhanced matching logic with confidence scores
        let lowercaseTitle = title.lowercased()
        let lowercaseDesc = description.lowercased()
        
        // Score each role based on title and description match
        var scoredRoles: [(role: Role, score: Double)] = []
        
        for mockRole in mockRoles {
            var score: Double = 0
            
            // Title matching
            if mockRole.title.lowercased() == lowercaseTitle {
                score += 0.5
            } else if mockRole.title.lowercased().contains(lowercaseTitle) || lowercaseTitle.contains(mockRole.title.lowercased()) {
                score += 0.3
            }
            
            // Description matching
            let roleDescWords = mockRole.description.lowercased().split(separator: " ")
            let userDescWords = lowercaseDesc.split(separator: " ")
            let commonWords = Set(roleDescWords).intersection(Set(userDescWords))
            score += Double(commonWords.count) * 0.02
            
            // Industry matching
            if mockRole.industry == industry || mockRole.industry == "Any" {
                score += 0.2
            }
            
            if score > 0 {
                scoredRoles.append((mockRole, min(score, 0.95)))
            }
        }
        
        // Sort by score and take top matches
        scoredRoles.sort { $0.score > $1.score }
        let topMatches = scoredRoles.prefix(3)
        
        if topMatches.isEmpty {
            return RoleMatchResponse(roles: [])
        } else {
            // Create roles with confidence scores
            let matchedRoles = topMatches.map { match in
                Role(
                    id: match.role.id,
                    title: match.role.title,
                    description: match.role.description,
                    industry: match.role.industry,
                    commonTasks: match.role.commonTasks,
                    confidence: match.score
                )
            }
            return RoleMatchResponse(roles: matchedRoles)
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
    
}