import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: TimeBiteTab = .actions

    var body: some View {
        ZStack {
            selectedContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                TimeBiteTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .actions:
            ActionView()
        case .goals:
            GoalsView()
        case .track:
            TrackView()
        case .reflect:
            DashView()
        }
    }
}

private enum TimeBiteTab: String, CaseIterable, Identifiable {
    case actions
    case goals
    case track
    case reflect

    var id: String { rawValue }

    var title: String {
        switch self {
        case .actions:
            return "Actions"
        case .goals:
            return "Goals"
        case .track:
            return "Track"
        case .reflect:
            return "Reflect"
        }
    }
}

private struct TimeBiteTabBar: View {
    @Binding var selectedTab: TimeBiteTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TimeBiteTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                        selectedTab = tab
                    }
                } label: {
                    TimeBiteTabItem(
                        tab: tab,
                        isSelected: selectedTab == tab
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(7)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(hex: 0x0A0B10))
        )
    }
}

private struct TimeBiteTabItem: View {
    let tab: TimeBiteTab
    let isSelected: Bool

    private let activeGradient = LinearGradient(
        colors: [Color(hex: 0x5EEAD4), Color(hex: 0x38BDF8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        VStack(spacing: 5) {
            icon
                .frame(width: 22, height: 22)

            Text(tab.title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .tracking(0.3)
                .foregroundStyle(isSelected ? Color(hex: 0x8FE9DD) : Color(hex: 0x5A6072))
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x1A2B3A), Color(hex: 0x0F1620)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(hex: 0x2A4A55), lineWidth: 1)
                    )
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        let lineWidth: CGFloat = 1.3

        switch tab {
        case .actions:
            tabIconShape(ActionSparkIcon(), lineWidth: lineWidth)
        case .goals:
            tabIconShape(GoalRingsIcon(), lineWidth: lineWidth)
        case .track:
            tabIconShape(TrackWaveIcon(), lineWidth: lineWidth)
        case .reflect:
            tabIconShape(ReflectCrescentIcon(), lineWidth: lineWidth)
        }
    }

    @ViewBuilder
    private func tabIconShape<S: Shape>(_ shape: S, lineWidth: CGFloat) -> some View {
        if isSelected {
            shape
                .stroke(
                    activeGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
        } else {
            shape
                .stroke(
                    Color(hex: 0x5A6072),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
        }
    }
}

private struct ActionSparkIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: 13, y: 2),
            CGPoint(x: 5, y: 14),
            CGPoint(x: 11, y: 14),
            CGPoint(x: 9, y: 22),
            CGPoint(x: 19, y: 9),
            CGPoint(x: 13, y: 9)
        ].map { point in
            CGPoint(
                x: rect.minX + point.x / 24 * rect.width,
                y: rect.minY + point.y / 24 * rect.height
            )
        }

        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}

private struct GoalRingsIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let side = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let scale = side / 24

        path.addEllipse(in: CGRect(
            x: center.x - 9 * scale,
            y: center.y - 9 * scale,
            width: 18 * scale,
            height: 18 * scale
        ))
        path.addEllipse(in: CGRect(
            x: center.x - 5 * scale,
            y: center.y - 5 * scale,
            width: 10 * scale,
            height: 10 * scale
        ))
        path.addEllipse(in: CGRect(
            x: center.x - 1.4 * scale,
            y: center.y - 1.4 * scale,
            width: 2.8 * scale,
            height: 2.8 * scale
        ))

        return path
    }
}

private struct TrackWaveIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + x / 24 * rect.width,
                y: rect.minY + y / 24 * rect.height
            )
        }

        path.move(to: point(2, 12))
        path.addCurve(to: point(7, 7), control1: point(3.7, 12), control2: point(4.8, 7))
        path.addCurve(to: point(12, 12), control1: point(9.2, 7), control2: point(10.3, 12))
        path.addCurve(to: point(17, 17), control1: point(13.7, 12), control2: point(14.8, 17))
        path.addCurve(to: point(22, 12), control1: point(19.2, 17), control2: point(20.3, 12))

        return path
    }
}

private struct ReflectCrescentIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let side = min(rect.width, rect.height)
        let scale = side / 24
        let center = CGPoint(x: rect.midX - 1.3 * scale, y: rect.midY)
        let innerCenter = CGPoint(x: rect.midX + 4.2 * scale, y: rect.midY - 0.4 * scale)

        path.addArc(
            center: center,
            radius: 8.7 * scale,
            startAngle: .degrees(104),
            endAngle: .degrees(256),
            clockwise: false
        )
        path.addArc(
            center: innerCenter,
            radius: 7.2 * scale,
            startAngle: .degrees(252),
            endAngle: .degrees(108),
            clockwise: true
        )

        return path
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
