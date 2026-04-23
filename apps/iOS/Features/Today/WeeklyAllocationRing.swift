import SwiftUI

public struct WeeklyAllocationRing: View {
    public struct Segment: Identifiable {
        public let id: UUID
        public var title: String
        public var fraction: Double
        public var color: Color

        public init(id: UUID = UUID(), title: String, fraction: Double, color: Color) {
            self.id = id
            self.title = title
            self.fraction = fraction
            self.color = color
        }
    }

    let segments: [Segment]

    public init(segments: [Segment]) {
        self.segments = segments
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let lineWidth = max(14, size * 0.12)
            let normalized = normalizedSegments(segments)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

                ForEach(Array(normalized.enumerated()), id: \.element.id) { idx, seg in
                    ringSegment(
                        seg: seg,
                        start: normalized.prefix(idx).map(\.fraction).reduce(0, +),
                        lineWidth: lineWidth
                    )
                }

                VStack(spacing: 4) {
                    Text("Planned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(dominantText(normalized))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 170)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weekly allocation ring")
    }

    private func ringSegment(seg: Segment, start: Double, lineWidth: CGFloat) -> some View {
        let gap: Double = 0.008
        let from = start + gap
        let to = start + seg.fraction - gap

        return Circle()
            .trim(from: max(0, from), to: min(1, to))
            .stroke(seg.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .shadow(color: seg.color.opacity(0.18), radius: 10, x: 0, y: 6)
    }

    private func normalizedSegments(_ segments: [Segment]) -> [Segment] {
        let total = segments.map(\.fraction).reduce(0, +)
        guard total > 0 else { return [] }
        return segments.map { seg in
            Segment(id: seg.id, title: seg.title, fraction: seg.fraction / total, color: seg.color)
        }
    }

    private func dominantText(_ segments: [Segment]) -> String {
        guard let dominant = segments.max(by: { $0.fraction < $1.fraction }) else { return "—" }
        let pct = dominant.fraction.formatted(.percent.precision(.fractionLength(0)))
        return "\(pct) \(dominant.title)"
    }
}

struct WeeklyAllocationRing_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            WeeklyAllocationRing(
                segments: [
                    .init(title: "Build", fraction: 0.60, color: .cyan),
                    .init(title: "Income", fraction: 0.25, color: .green),
                    .init(title: "Brand", fraction: 0.15, color: .purple),
                ]
            )
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
