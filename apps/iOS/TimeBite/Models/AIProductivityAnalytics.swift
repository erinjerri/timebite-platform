import Foundation

struct AIProductivityAnalytics {
    var completionRateWeight: Double = 0.30
    var focusTimeWeight: Double = 0.25
    var goalAlignmentWeight: Double = 0.25
    var aiLeverageWeight: Double = 0.20

    func workSummary(for sessions: [AgentSession]) -> AIWorkSummary {
        let totalRuntime = sessions.map(\.runtime).reduce(0, +)
        let totalPrompts = sessions.map(\.promptCount).reduce(0, +)
        let totalCost = sessions.map(\.estimatedCost).reduce(0, +)
        let totalInterventions = sessions.map(\.interventionCount).reduce(0, +)
        let completedSessions = sessions.filter(\.isComplete).count

        return AIWorkSummary(
            totalSessions: sessions.count,
            totalRuntime: totalRuntime,
            totalPrompts: totalPrompts,
            totalCost: totalCost,
            interventionRate: ratio(Double(totalInterventions), Double(max(totalPrompts, 1))),
            completionRate: ratio(Double(completedSessions), Double(max(sessions.count, 1))),
            humanHoursSavedEstimate: estimateHoursSaved(sessions: sessions)
        )
    }

    func aiLeverageScore(outputAchieved: Double, humanEffortInvested: TimeInterval) -> Double {
        let hours = max(humanEffortInvested / 3600, 0.25)
        return outputAchieved / hours
    }

    func humanJudgmentRatio(humanInterventions: Int, aiActions: Int) -> Double {
        ratio(Double(humanInterventions), Double(max(aiActions, 1)))
    }

    func goalAlignmentScore(alignedTime: TimeInterval, totalTime: TimeInterval) -> Double {
        ratio(alignedTime, max(totalTime, 1))
    }

    func executionQualityScore(
        completionRate: Double,
        focusTime: TimeInterval,
        plannedFocusTime: TimeInterval,
        goalAlignment: Double,
        aiLeverage: Double
    ) -> Double {
        let focusScore = ratio(focusTime, max(plannedFocusTime, 1))
        let normalizedLeverage = min(max(aiLeverage / 10, 0), 1)
        return min(
            completionRate * completionRateWeight
            + focusScore * focusTimeWeight
            + goalAlignment * goalAlignmentWeight
            + normalizedLeverage * aiLeverageWeight,
            1
        )
    }

    private func estimateHoursSaved(sessions: [AgentSession]) -> Double {
        sessions.reduce(0) { partial, session in
            let runtimeHours = session.runtime / 3600
            let complexityMultiplier = session.isComplete ? 1.9 : 0.8
            let promptLift = min(Double(session.promptCount) * 0.08, 1.2)
            return partial + runtimeHours * complexityMultiplier + promptLift
        }
    }

    private func ratio(_ numerator: Double, _ denominator: Double) -> Double {
        min(max(numerator / denominator, 0), 1)
    }
}
