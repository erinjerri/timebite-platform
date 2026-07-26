import SwiftUI

enum GoalFormStyle {
    static var background: some View {
        LinearGradient(
            colors: [
                TBColor.background,
                Color(red: 0.03, green: 0.11, blue: 0.14),
                TBColor.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    static var inputBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(TBColor.surfaceElevated.opacity(0.82))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(TBColor.border, lineWidth: 1)
            )
    }

    static func intro(headline: String, subtext: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(headline)
                .font(TBTypography.title(.title3, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)

            Text(subtext)
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(TBColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(TBColor.primaryAccent.opacity(0.18), lineWidth: 1)
                )
        )
    }

    static func field<Content: View>(
        _ label: String,
        isRequired: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)

                if isRequired {
                    Text("*")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }
            }
            content()
        }
    }

    static func textField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(TBTypography.body(.semibold))
            .foregroundStyle(TBColor.textPrimary)
            .textInputAutocapitalization(.sentences)
            .padding(14)
            .background(inputBackground)
    }
}
