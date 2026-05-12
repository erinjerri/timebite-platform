import SwiftUI

enum TBTheme {
    static let backgroundTop = Color(red: 0.039, green: 0.059, blue: 0.110)
    static let backgroundBottom = Color(red: 0.016, green: 0.020, blue: 0.032)
    static let field = Color(red: 0.067, green: 0.082, blue: 0.118)
    static let panel = Color.white.opacity(0.040)
    static let panelStrong = Color.white.opacity(0.070)
    static let stroke = Color.white.opacity(0.115)
    static let primaryText = Color(red: 0.94, green: 0.955, blue: 0.975)
    static let secondaryText = Color(red: 0.62, green: 0.65, blue: 0.72)
    static let tertiaryText = Color(red: 0.42, green: 0.46, blue: 0.54)
    static let cyan = Color(red: 0.40, green: 0.86, blue: 0.96)
    static let indigo = Color(red: 0.61, green: 0.54, blue: 0.98)
    static let green = Color(red: 0.62, green: 0.90, blue: 0.66)
    static let graphite = Color(red: 0.067, green: 0.082, blue: 0.118)

    static let pageGradient = LinearGradient(
        colors: [backgroundTop, Color(red: 0.035, green: 0.043, blue: 0.070), backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [cyan, Color(red: 0.48, green: 0.58, blue: 1.0), indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func laneColor(_ laneType: FocusLaneType) -> Color {
        switch laneType {
        case .app:
            return cyan
        case .income:
            return indigo
        case .brand:
            return green
        }
    }
}

enum TBMotion {
    static let tap = Animation.spring(response: 0.22, dampingFraction: 0.82)
    static let state = Animation.spring(response: 0.36, dampingFraction: 0.86)
    static let page = Animation.spring(response: 0.46, dampingFraction: 0.90)
    static let depletion = Animation.timingCurve(0.22, 0.0, 0.0, 1.0, duration: 0.42)
}

struct TBScreen<Content: View>: View {
    let title: String
    let eyebrow: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(eyebrow.uppercased())
                            .font(.caption.weight(.semibold))
                            .tracking(1.8)
                            .foregroundStyle(TBTheme.secondaryText)
                        Text(title)
                            .font(.system(size: 34, weight: .medium, design: .default))
                            .foregroundStyle(TBTheme.primaryText)
                    }
                    .padding(.top, 14)

                    content()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 108)
            }
            .scrollIndicators(.hidden)
            .background(TBBackground())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct TBBackground: View {
    var body: some View {
        ZStack {
            TBTheme.pageGradient.ignoresSafeArea()

            TBGridOverlay()
                .opacity(0.70)
                .ignoresSafeArea()

            Circle()
                .fill(TBTheme.indigo.opacity(0.18))
                .blur(radius: 120)
                .frame(width: 360, height: 360)
                .offset(x: -120, y: -190)

            Circle()
                .fill(TBTheme.cyan.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 280, height: 280)
                .offset(x: 155, y: 340)
        }
    }
}

struct TBGridOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let columns = 4
                let columnWidth = size.width / CGFloat(columns)
                var verticals = Path()

                for index in 0...columns {
                    let x = CGFloat(index) * columnWidth
                    verticals.move(to: CGPoint(x: x, y: 0))
                    verticals.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(verticals, with: .color(.white.opacity(0.030)), lineWidth: 1)

                var diagonals = Path()
                let step: CGFloat = 24
                var start: CGFloat = -size.height
                while start < size.width {
                    diagonals.move(to: CGPoint(x: start, y: size.height))
                    diagonals.addLine(to: CGPoint(x: start + size.height, y: 0))
                    start += step
                }
                context.stroke(diagonals, with: .color(.white.opacity(0.014)), lineWidth: 1)

                var frame = Path()
                frame.addRect(CGRect(origin: .zero, size: proxy.size).insetBy(dx: 0.5, dy: 0.5))
                context.stroke(frame, with: .color(.white.opacity(0.035)), lineWidth: 1)
            }
        }
    }
}

struct TBCard<Content: View>: View {
    var isProminent = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding(isProminent ? 22 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TBGlassBackground(radius: isProminent ? 26 : 18, isProminent: isProminent))
    }
}

struct TBGlassBackground: View {
    var radius: CGFloat = 18
    var isProminent = false

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(isProminent ? TBTheme.panelStrong : TBTheme.panel)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(TBTheme.stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(isProminent ? 0.46 : 0.22), radius: isProminent ? 34 : 18, x: 0, y: isProminent ? 24 : 12)
    }
}

struct TBFieldSurface<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TBTheme.field.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TBTheme.stroke.opacity(0.75), lineWidth: 1)
            )
    }
}

struct TBSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(TBTheme.primaryText)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(TBTheme.secondaryText)
            }
        }
    }
}

struct TBMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 34, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(TBTheme.primaryText)
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(TBTheme.secondaryText)
        }
    }
}

struct TBPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(TBTheme.accentGradient, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(TBMotion.tap, value: configuration.isPressed)
    }
}

enum TBIconKind: Equatable {
    case action
    case dash
    case goals
    case reflect
    case lane(FocusLaneType)
}

struct TBIconView: View {
    let kind: TBIconKind
    var color = TBTheme.primaryText
    var lineWidth: CGFloat = 1.8

    var body: some View {
        Canvas { context, size in
            var path = Path()
            let rect = CGRect(origin: .zero, size: size)
            let inset = lineWidth + 2

            switch kind {
            case .action:
                path.addArc(
                    center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: min(size.width, size.height) * 0.34,
                    startAngle: .degrees(-36),
                    endAngle: .degrees(286),
                    clockwise: false
                )
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                context.fill(Path(ellipseIn: CGRect(x: rect.midX - 2.2, y: rect.midY - 2.2, width: 4.4, height: 4.4)), with: .color(color.opacity(0.85)))
            case .dash:
                for index in 0..<3 {
                    let ringInset = inset + CGFloat(index) * 4.1
                    var ring = Path()
                    ring.addArc(
                        center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: max(2, min(size.width, size.height) * 0.46 - ringInset),
                        startAngle: .degrees(-88),
                        endAngle: .degrees(210 - Double(index * 24)),
                        clockwise: false
                    )
                    context.stroke(ring, with: .color(color.opacity(1 - Double(index) * 0.18)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                }
            case .goals:
                path.move(to: CGPoint(x: rect.midX, y: inset))
                path.addLine(to: CGPoint(x: size.width - inset, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.midX, y: size.height - inset))
                path.addLine(to: CGPoint(x: inset, y: rect.midY))
                path.closeSubpath()
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                context.fill(Path(ellipseIn: CGRect(x: rect.midX - 2, y: rect.midY - 2, width: 4, height: 4)), with: .color(color.opacity(0.8)))
            case .reflect:
                path.move(to: CGPoint(x: inset + 2, y: size.height - inset))
                path.addLine(to: CGPoint(x: rect.midX, y: inset + 1))
                path.addLine(to: CGPoint(x: size.width - inset - 1, y: size.height - inset))
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            case .lane(let laneType):
                drawLaneIcon(laneType, context: &context, rect: rect, inset: inset)
            }
        }
        .frame(width: 24, height: 24)
    }

    private func drawLaneIcon(_ laneType: FocusLaneType, context: inout GraphicsContext, rect: CGRect, inset: CGFloat) {
        switch laneType {
        case .app:
            let rounded = Path(roundedRect: rect.insetBy(dx: inset + 2, dy: inset + 2), cornerRadius: 5)
            context.stroke(rounded, with: .color(color), lineWidth: lineWidth)
        case .income:
            for index in 0..<3 {
                let height = CGFloat(index + 2) * 4.4
                let x = inset + CGFloat(index) * 6.2 + 3
                let path = Path(roundedRect: CGRect(x: x, y: rect.maxY - inset - height, width: 3.5, height: height), cornerRadius: 2)
                context.fill(path, with: .color(color.opacity(0.72 + Double(index) * 0.12)))
            }
        case .brand:
            var prism = Path()
            prism.move(to: CGPoint(x: rect.midX, y: inset + 2))
            prism.addLine(to: CGPoint(x: rect.maxX - inset - 2, y: rect.midY + 2))
            prism.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - inset - 1))
            prism.addLine(to: CGPoint(x: inset + 2, y: rect.midY + 2))
            prism.closeSubpath()
            context.stroke(prism, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
        }
    }
}

