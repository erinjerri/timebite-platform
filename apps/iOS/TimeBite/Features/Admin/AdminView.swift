import Charts
import SwiftUI

struct AdminView: View {
    let onLock: () -> Void

    private let telemetryEvents = TelemetryEvent.sampleData
    private let agentRuns = AgentRun.sampleData
    private let logEntries = AdminLogEntry.sampleData
    private let featureFlags = FeatureFlag.sampleData

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    telemetrySection
                    agentRunsSection
                    logsSection
                    featureFlagsSection
                    lockButton
                }
                .padding(16)
                .padding(.bottom, 104)
            }
            .background(background)
            .navigationTitle("Admin")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Admin")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(TBColor.textPrimary)

            Text("Founder-only development tooling for local telemetry, agent runs, logs, and feature flags.")
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textSecondary)
        }
    }

    private var telemetrySection: some View {
        adminSection(title: "Telemetry", icon: "waveform.path.ecg") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                telemetryMetric(title: "Events", value: "\(telemetryEvents.count)", tint: TBColor.primaryAccent)
                telemetryMetric(title: "Success", value: "98%", tint: Color(red: 0.39, green: 0.77, blue: 0.98))
                telemetryMetric(title: "P95", value: "420ms", tint: TBColor.gold)
            }

            Chart(telemetryEvents) { event in
                BarMark(
                    x: .value("Surface", event.surface),
                    y: .value("Count", event.count)
                )
                .foregroundStyle(event.tint)
                .cornerRadius(8)
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label).foregroundStyle(TBColor.textSecondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }

    private var agentRunsSection: some View {
        adminSection(title: "Agent Runs", icon: "terminal") {
            VStack(spacing: 10) {
                ForEach(agentRuns) { run in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(run.task)
                                    .font(TBTypography.body(.semibold))
                                    .foregroundStyle(TBColor.textPrimary)
                                Text(run.tool)
                                    .font(TBTypography.caption())
                                    .foregroundStyle(TBColor.textSecondary)
                            }

                            Spacer()

                            Text(run.status)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(run.statusTint)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 9)
                                .background(Capsule(style: .continuous).fill(run.statusTint.opacity(0.12)))
                        }

                        HStack {
                            Text(run.startedAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                            Spacer()
                            Text(run.completedAt?.formatted(.dateTime.hour().minute()) ?? "Running")
                        }
                        .font(TBTypography.caption())
                        .foregroundStyle(TBColor.textSecondary)

                        Text(run.logs.joined(separator: "\n"))
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundStyle(TBColor.textSecondary)
                            .lineLimit(3)
                    }
                    .padding(14)
                    .background(adminRowBackground)
                }
            }
        }
    }

    private var logsSection: some View {
        adminSection(title: "Logs", icon: "doc.text.magnifyingglass") {
            VStack(spacing: 8) {
                ForEach(logEntries) { entry in
                    HStack(alignment: .top, spacing: 10) {
                        Text(entry.level)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(entry.tint)
                            .frame(width: 44, alignment: .leading)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.message)
                                .font(TBTypography.caption(.semibold))
                                .foregroundStyle(TBColor.textPrimary)
                            Text(entry.timestamp.formatted(.dateTime.hour().minute().second()))
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                .foregroundStyle(TBColor.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(adminRowBackground)
                }
            }
        }
    }

    private var featureFlagsSection: some View {
        adminSection(title: "Feature Flags", icon: "switch.2") {
            VStack(spacing: 10) {
                ForEach(featureFlags) { flag in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(flag.isEnabled ? TBColor.primaryAccent : TBColor.textSecondary)
                            .frame(width: 9, height: 9)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(flag.name)
                                .font(TBTypography.body(.semibold))
                                .foregroundStyle(TBColor.textPrimary)
                            Text(flag.description)
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                        }

                        Spacer()

                        Text(flag.isEnabled ? "On" : "Off")
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(flag.isEnabled ? TBColor.primaryAccent : TBColor.textSecondary)
                    }
                    .padding(14)
                    .background(adminRowBackground)
                }
            }
        }
    }

    private var lockButton: some View {
        Button(action: onLock) {
            HStack {
                Image(systemName: "lock.fill")
                Text("Lock Admin Mode")
            }
            .font(TBTypography.body(.semibold))
            .foregroundStyle(TBColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(TBColor.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(TBColor.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        LinearGradient(
            colors: [TBColor.background, TBColor.surface.opacity(0.40), TBColor.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func adminSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        TBCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(TBColor.primaryAccent.opacity(0.12)))

                    Text(title)
                        .font(TBTypography.title(.headline, weight: .semibold))
                        .foregroundStyle(TBColor.textPrimary)

                    Spacer()
                }

                content()
            }
        }
    }

    private func telemetryMetric(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(TBColor.textPrimary)
            Text(title)
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(TBColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(tint.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(tint.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var adminRowBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(TBColor.surfaceElevated.opacity(0.76))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(TBColor.border, lineWidth: 1)
            )
    }
}

struct AgentRun: Identifiable, Hashable {
    let id = UUID()
    var task: String
    var status: String
    var startedAt: Date
    var completedAt: Date?
    var tool: String
    var logs: [String]

    var statusTint: Color {
        switch status.lowercased() {
        case "completed":
            return TBColor.primaryAccent
        case "running":
            return Color(red: 0.39, green: 0.77, blue: 0.98)
        default:
            return TBColor.gold
        }
    }
}

private extension AgentRun {
    static let sampleData: [AgentRun] = [
        .init(
            task: "Generate goal timeline scaffold",
            status: "Completed",
            startedAt: Date().addingTimeInterval(-9200),
            completedAt: Date().addingTimeInterval(-8700),
            tool: "Codex",
            logs: ["Loaded GoalsView.swift", "Added Timeline mode", "xcodebuild succeeded"]
        ),
        .init(
            task: "Inspect OpenHands handoff hooks",
            status: "Running",
            startedAt: Date().addingTimeInterval(-1800),
            completedAt: nil,
            tool: "OpenHands",
            logs: ["Queued repository scan", "Awaiting sandbox connection"]
        ),
        .init(
            task: "Summarize telemetry schema",
            status: "Pending",
            startedAt: Date().addingTimeInterval(600),
            completedAt: nil,
            tool: "Codex",
            logs: ["Scheduled locally"]
        )
    ]
}

private struct TelemetryEvent: Identifiable {
    let id = UUID()
    var surface: String
    var count: Int
    var tint: Color
}

private extension TelemetryEvent {
    static let sampleData: [TelemetryEvent] = [
        .init(surface: "Actions", count: 42, tint: TBColor.primaryAccent),
        .init(surface: "Goals", count: 31, tint: Color(red: 0.39, green: 0.77, blue: 0.98)),
        .init(surface: "Track", count: 24, tint: TBColor.gold),
        .init(surface: "Reflect", count: 18, tint: TBColor.secondaryAccent)
    ]
}

private struct AdminLogEntry: Identifiable {
    let id = UUID()
    var level: String
    var message: String
    var timestamp: Date

    var tint: Color {
        switch level {
        case "WARN":
            return TBColor.gold
        case "ERR":
            return Color(red: 0.98, green: 0.36, blue: 0.36)
        default:
            return TBColor.primaryAccent
        }
    }
}

private extension AdminLogEntry {
    static let sampleData: [AdminLogEntry] = [
        .init(level: "INFO", message: "SwiftData model container initialized.", timestamp: Date().addingTimeInterval(-450)),
        .init(level: "INFO", message: "Admin unlock state loaded from AppStorage.", timestamp: Date().addingTimeInterval(-300)),
        .init(level: "WARN", message: "Agent telemetry is currently sample-only.", timestamp: Date().addingTimeInterval(-120))
    ]
}

private struct FeatureFlag: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var isEnabled: Bool
}

private extension FeatureFlag {
    static let sampleData: [FeatureFlag] = [
        .init(name: "goals.timeline", description: "Native Gantt-style goal planning.", isEnabled: true),
        .init(name: "agents.openhands", description: "Future OpenHands run ingestion.", isEnabled: false),
        .init(name: "agents.codexTelemetry", description: "Codex task logs and artifacts.", isEnabled: true),
        .init(name: "debug.verboseLogs", description: "Show expanded local diagnostic logs.", isEnabled: false)
    ]
}

#if DEBUG
struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView(onLock: {})
            .preferredColorScheme(.dark)
    }
}
#endif

