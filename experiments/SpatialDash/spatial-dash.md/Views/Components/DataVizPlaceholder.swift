import SwiftUI

struct DataVizPlaceholder: View {
    let tokens: DesignTokens
    let compact: Bool

    private let values: [CGFloat] = [0.32, 0.72, 0.54, 0.88, 0.46, 0.64, 0.78]

    var body: some View {
        HStack(alignment: .bottom, spacing: tokens.spacing.compact) {
            ForEach(values.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(tokens.dataViz.palette[index % tokens.dataViz.palette.count])
                    .frame(height: (compact ? 86 : 132) * values[index])
                    .opacity(index == 3 ? 1 : 0.72)
            }
        }
        .frame(maxWidth: .infinity, minHeight: compact ? 96 : 148, alignment: .bottom)
        .padding(.top, tokens.spacing.compact)
        .accessibilityLabel("Productivity rhythm data visualization")
    }
}

