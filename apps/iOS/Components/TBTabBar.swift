import SwiftUI

enum TBTab: String, CaseIterable, Identifiable {
    case actions
    case dash
    case goals
    case reflect

    var id: String { rawValue }

    var title: String {
        switch self {
        case .actions: return "Action"
        case .dash: return "Dash"
        case .goals: return "Intent"
        case .reflect: return "Reflect"
        }
    }

    var icon: TBIconKind {
        switch self {
        case .actions: return .action
        case .dash: return .dash
        case .goals: return .goals
        case .reflect: return .reflect
        }
    }
}

struct TBTabBar: View {
    @Binding var selection: TBTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TBTab.allCases) { tab in
                Button {
                    withAnimation(TBMotion.state) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack(alignment: .bottom) {
                            TBIconView(kind: tab.icon, color: selection == tab ? TBTheme.primaryText : TBTheme.secondaryText, lineWidth: 1.7)
                                .frame(width: 24, height: 24)

                            if selection == tab {
                                Circle()
                                    .fill(TBTheme.cyan)
                                    .frame(width: 4, height: 4)
                                    .offset(y: 7)
                                    .matchedGeometryEffect(id: "selected-tab-dot", in: namespace)
                            }
                        }
                        Text(tab.title)
                            .font(.caption2.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .foregroundStyle(selection == tab ? TBTheme.primaryText : TBTheme.secondaryText)
                    .background {
                        if selection == tab {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.075))
                                .matchedGeometryEffect(id: "selected-tab", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.055, green: 0.060, blue: 0.078).opacity(0.86))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.50), radius: 34, y: 18)
        )
        .padding(.horizontal, 20)
    }

    @Namespace private var namespace
}
