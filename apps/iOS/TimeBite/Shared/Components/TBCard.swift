import SwiftUI

struct TBCard<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

    init(padding: CGFloat = TBSpacing.lg, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(TBColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(TBColor.border, lineWidth: 1)
                    )
                    .shadow(color: TBShadow.card, radius: 18, x: 0, y: 10)
            )
    }
}

extension View {
    func tbCard() -> some View {
        modifier(TBCardPaddingModifier())
    }
}

private struct TBCardPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

