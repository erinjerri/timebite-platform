import Foundation

enum MockGoalData {
    static let goals: [GoalItem] = [
        .init(
            title: "Launch TimeBite iPhone MVP",
            phase: "Short-Term",
            summary: "Deliver the portfolio-grade core loop with action, tracking, goals, and analytics.",
            category: .build,
            status: .active,
            progress: 0.76,
            targetDate: "May 24, 2026",
            badges: ["MVP", "iPhone-first", "Local data"],
            checkpoints: ["Action tab done", "Tracking tab polished", "Dashboard charts in place"],
            details: [
                "Keep the surface calm and tactile.",
                "Prioritize completion over scope.",
                "Use the screenshots as layout rhythm, not a literal clone."
            ]
        ),
        .init(
            title: "Grow daily execution consistency",
            phase: "Intermediate",
            summary: "Build a habit loop around one action, tracked sessions, and a reflective close.",
            category: .growth,
            status: .onTrack,
            progress: 0.58,
            targetDate: "Jun 30, 2026",
            badges: ["Streak", "Reflection", "Focus"],
            checkpoints: ["Daily intent", "Timer proof", "Nightly review"],
            details: [
                "Measure time spent on the thing that matters most.",
                "Bias the UI toward the next action, not the backlog.",
                "Keep feedback immediate and legible."
            ]
        ),
        .init(
            title: "Protect deep work and recovery",
            phase: "Long-Term",
            summary: "Keep energy and output balanced so the system feels sustainable.",
            category: .health,
            status: .atRisk,
            progress: 0.34,
            targetDate: "Q3 2026",
            badges: ["Balance", "Energy", "Recovery"],
            checkpoints: ["Movement breaks", "Sleep window", "Fewer open loops"],
            details: [
                "Use the tracker to make recovery visible.",
                "Avoid turning the app into another noisy dashboard.",
                "Let the tone stay premium and grounded."
            ]
        )
    ]
}

