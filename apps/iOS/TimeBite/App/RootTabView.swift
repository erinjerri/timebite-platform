import SwiftUI

struct RootTabView: View {
    @AppStorage("isAdmin") private var isAdmin = false
    @AppStorage("adminPassword") private var adminPassword = "timebite-founder"
    @State private var selectedTab: TimeBiteTab = .actions
    @State private var versionTapCount = 0
    @State private var showingAdminUnlock = false

    init() {}

    fileprivate init(initialTab: TimeBiteTab) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TBColor.background
                .ignoresSafeArea()

            selectedContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            adminLogoUnlock
                .padding(.top, 10)
                .padding(.leading, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .bottom) {
            bottomNavigationBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAdminUnlock) {
            AdminUnlockSheet(
                storedPassword: adminPassword,
                onUnlock: {
                    isAdmin = true
                    showingAdminUnlock = false
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                        selectedTab = .admin
                    }
                },
                onCancel: {
                    showingAdminUnlock = false
                }
            )
            .preferredColorScheme(.dark)
        }
        .onChange(of: isAdmin) { _, newValue in
            if !newValue && selectedTab == .admin {
                selectedTab = .actions
            }
        }
    }

    private var bottomNavigationBar: some View {
        VStack(spacing: 4) {
            appVersionUnlock

            TimeBiteTabBar(selectedTab: $selectedTab, availableTabs: availableTabs)
                .padding(.horizontal, 16)
        }
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [
                    TBColor.background.opacity(0),
                    TBColor.background.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
        )
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
        case .admin:
            AdminView(onLock: {
                isAdmin = false
            })
        }
    }

    private var availableTabs: [TimeBiteTab] {
        TimeBiteTab.allCases.filter { tab in
            tab != .admin || isAdmin
        }
    }

    private var adminLogoUnlock: some View {
        Text("TimeBite")
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(TBColor.textPrimary.opacity(0.18))
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 1.2) {
                showingAdminUnlock = true
            }
            .accessibilityHidden(true)
    }

    private var appVersionUnlock: some View {
        Text("v\(appVersion)")
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(TBColor.textSecondary.opacity(0.28))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                versionTapCount += 1
                if versionTapCount >= 7 {
                    versionTapCount = 0
                    showingAdminUnlock = true
                }
            }
            .accessibilityHidden(true)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

private struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootTabView(initialTab: .reflect)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 16e")
                .previewDisplayName("Reflect - iPhone 16e")

            RootTabView(initialTab: .reflect)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 16 Pro")
                .previewDisplayName("Reflect - iPhone 16 Pro")

            RootTabView(initialTab: .reflect)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 17 Pro")
                .previewDisplayName("Reflect - iPhone 17 Pro")
        }
    }
}

private struct AdminUnlockSheet: View {
    let storedPassword: String
    let onUnlock: () -> Void
    let onCancel: () -> Void

    @State private var password = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Admin Mode")
                        .font(TBTypography.title(.title2, weight: .bold))
                        .foregroundStyle(TBColor.textPrimary)

                    Text("Founder-only local access to development tooling.")
                        .font(TBTypography.body())
                        .foregroundStyle(TBColor.textSecondary)
                }

                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(TBColor.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(showError ? TBColor.gold.opacity(0.5) : TBColor.border, lineWidth: 1)
                            )
                    )

                if showError {
                    Text("Incorrect password.")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.gold)
                }

                Spacer()

                Button {
                    if password == storedPassword {
                        onUnlock()
                    } else {
                        showError = true
                    }
                } label: {
                    Text("Unlock")
                        .font(TBTypography.body(.semibold))
                        .foregroundStyle(Color.black.opacity(0.86))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(TBColor.primaryAccent)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(TBColor.background.ignoresSafeArea())
            .navigationTitle("Unlock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(TBColor.textSecondary)
                }
            }
        }
    }
}

fileprivate enum TimeBiteTab: String, CaseIterable, Identifiable {
    case actions
    case goals
    case track
    case reflect
    case admin

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
        case .admin:
            return "Admin"
        }
    }
}

private struct TimeBiteTabBar: View {
    @Binding var selectedTab: TimeBiteTab
    let availableTabs: [TimeBiteTab]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(availableTabs) { tab in
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
        case .admin:
            tabIconShape(AdminKeyIcon(), lineWidth: lineWidth)
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

private struct AdminKeyIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scale = min(rect.width, rect.height) / 24
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + x * scale,
                y: rect.minY + y * scale
            )
        }

        path.addEllipse(in: CGRect(
            x: rect.minX + 3 * scale,
            y: rect.minY + 5 * scale,
            width: 8 * scale,
            height: 8 * scale
        ))
        path.move(to: point(10, 12))
        path.addLine(to: point(21, 21))
        path.move(to: point(16, 18))
        path.addLine(to: point(18, 16))
        path.move(to: point(18, 20))
        path.addLine(to: point(20, 18))

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
