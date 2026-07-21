import AuthenticationServices
import SwiftUI

struct AuthenticationGate<Content: View>: View {
    @StateObject private var authentication: AuthenticationStore
    @State private var betaCode = ""
    @State private var showingBetaCode = false
    private let content: () -> Content

    init(authentication: AuthenticationStore, @ViewBuilder content: @escaping () -> Content) {
        _authentication = StateObject(wrappedValue: authentication)
        self.content = content
    }

    var body: some View {
        Group {
            switch authentication.state {
            case .signedIn:
                content().environmentObject(authentication)
            case .restoring, .signingIn:
                ProgressView("Restoring your TimeBite data…")
            case let .error(message):
                signIn(message: message)
            case .signedOut:
                signIn(message: nil)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TBColor.background.ignoresSafeArea())
    }

    private func signIn(message: String?) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(TBColor.primaryAccent)
            Text("TimeBite")
                .font(TBTypography.title(.largeTitle, weight: .bold))
                .foregroundStyle(TBColor.textPrimary)
            Text("Your goals and sessions stay available offline and sync privately across your devices.")
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textSecondary)
                .multilineTextAlignment(.center)
            if let message {
                Text(message).font(TBTypography.caption()).foregroundStyle(.red)
            }

            SignInWithAppleButton(.continue) { request in
                authentication.prepare(request)
            } onCompletion: { result in
                Task { await authentication.complete(result) }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 52)

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                    showingBetaCode.toggle()
                }
            } label: {
                Label("Use beta code", systemImage: "number.square")
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.primaryAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(TBColor.surfaceElevated)
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(TBColor.border, lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)

            if showingBetaCode {
                VStack(spacing: 10) {
                    TextField("6-digit code", text: $betaCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(TBColor.textPrimary)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(TBColor.surface)
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(TBColor.border, lineWidth: 1))
                        )
                        .onChange(of: betaCode) { _, newValue in
                            betaCode = String(newValue.filter(\.isNumber).prefix(6))
                        }

                    Button {
                        authentication.signInWithBetaCode(betaCode)
                    } label: {
                        Text("Continue")
                            .font(TBTypography.body(.semibold))
                            .foregroundStyle(Color.black.opacity(0.86))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(betaCode.count == 6 ? TBColor.primaryAccent : TBColor.textSecondary.opacity(0.22))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(betaCode.count != 6)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(28)
        .frame(maxWidth: 460)
    }
}
