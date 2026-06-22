import Foundation
import SwiftData

@Model
final class DailyAIReflection {
    @Attribute(.unique) var id: UUID
    var date: Date
    var meaningfulProgressResponse: String
    var mostBenefitedTaskResponse: String
    var humanJudgmentResponse: String
    var automationCandidateResponse: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        date: Date = .now,
        meaningfulProgressResponse: String = "",
        mostBenefitedTaskResponse: String = "",
        humanJudgmentResponse: String = "",
        automationCandidateResponse: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.meaningfulProgressResponse = meaningfulProgressResponse
        self.mostBenefitedTaskResponse = mostBenefitedTaskResponse
        self.humanJudgmentResponse = humanJudgmentResponse
        self.automationCandidateResponse = automationCandidateResponse
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
