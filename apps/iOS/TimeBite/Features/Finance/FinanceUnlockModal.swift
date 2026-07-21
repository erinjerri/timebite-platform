import SwiftUI

struct FinanceUnlockModal: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: FinanceUnlockViewModel
    @State private var isVisible = false

    init(
        stage: FinanceUnlockStage,
        connector: any FinanceAccountConnecting,
        onConnected: @escaping (FinanceUnlockStage) -> Void = { _ in },
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: FinanceUnlockViewModel(
                stage: stage,
                connector: connector,
                onConnected: onConnected,
                onDismiss: onDismiss
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                card
                Spacer(minLength: 24)
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity, minHeight: 620)
            .padding(.horizontal, 20)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(TBColor.financeModalBackground(for: colorScheme).ignoresSafeArea())
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.52, dampingFraction: 0.82)) {
                isVisible = true
            }
        }
    }

    private var card: some View {
        VStack(spacing: 24) {
            illustration

            VStack(spacing: 12) {
                Text(viewModel.stage.headline)
                    .font(TBTypography.title(.title, weight: .bold))
                    .foregroundStyle(TBColor.financeModalTextPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(viewModel.stage.description)
                    .font(TBTypography.body())
                    .foregroundStyle(TBColor.financeModalTextSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            actions

            if let footer = viewModel.stage.footer {
                Label {
                    Text(footer)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "lock.shield.fill")
                        .accessibilityHidden(true)
                }
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.financeModalTextSecondary(for: colorScheme))
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TBColor.financeModalSurface(for: colorScheme))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(TBColor.financeModalBorder(for: colorScheme), lineWidth: 1)
                }
                .shadow(
                    color: TBColor.financeModalShadow(for: colorScheme),
                    radius: 24,
                    y: 12
                )
        )
        .scaleEffect(isVisible ? 1 : 0.96)
        .opacity(isVisible ? 1 : 0)
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(TBColor.accentGradient.opacity(0.16))
                .frame(width: 112, height: 112)

            Circle()
                .stroke(TBColor.primaryAccent.opacity(0.2), lineWidth: 1)
                .frame(width: 88, height: 88)

            Image(systemName: viewModel.stage.symbolName)
                .font(.system(size: 40, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(TBColor.primaryAccent)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.stage.accessibilityIllustrationLabel)
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                Task { await viewModel.connect() }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isConnecting {
                        ProgressView()
                            .tint(TBColor.financeModalButtonText)
                            .accessibilityHidden(true)
                    }

                    if viewModel.isConnecting {
                        Text("Connecting…")
                            .font(TBTypography.body(.semibold))
                    } else {
                        Text(viewModel.stage.primaryActionTitle)
                            .font(TBTypography.body(.semibold))
                    }
                }
                .foregroundStyle(TBColor.financeModalButtonText)
                .frame(maxWidth: .infinity, minHeight: 52)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(TBColor.primaryAccent)
                )
            }
            .buttonStyle(FinanceUnlockButtonStyle(reduceMotion: reduceMotion))
            .disabled(viewModel.isConnecting)
            .accessibilityHint("Begins a secure account connection")

            Button("Not Now", action: viewModel.dismiss)
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.financeModalTextSecondary(for: colorScheme))
                .frame(maxWidth: .infinity, minHeight: 48)
                .contentShape(Rectangle())
                .buttonStyle(FinanceUnlockButtonStyle(reduceMotion: reduceMotion))
                .disabled(viewModel.isConnecting)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.financeModalError)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Connection error: \(errorMessage)")
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(
            reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.86),
            value: viewModel.errorMessage
        )
    }
}

private struct FinanceUnlockButtonStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.8),
                value: configuration.isPressed
            )
    }
}

#if DEBUG
struct FinanceUnlockModal_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(for: .checking)
                .previewDisplayName("Stage 2 · Checking · Light")
                .preferredColorScheme(.light)

            preview(for: .savings)
                .previewDisplayName("Stage 3 · Savings · Dark")
                .preferredColorScheme(.dark)

            preview(for: .investments)
                .previewDisplayName("Stage 4 · Investments · AX5")
                .preferredColorScheme(.light)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }

    private static func preview(for stage: FinanceUnlockStage) -> some View {
        FinanceUnlockModal(
            stage: stage,
            connector: StubFinanceAccountConnector(),
            onDismiss: {}
        )
    }
}
#endif
