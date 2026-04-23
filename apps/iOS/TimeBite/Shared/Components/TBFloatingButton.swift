import SwiftUI

struct TBFloatingButton: View {
    let systemName: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(TBColor.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(tint.opacity(0.22))
                        .overlay(Circle().stroke(tint.opacity(0.42), lineWidth: 1))
                )
                .shadow(color: tint.opacity(0.24), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

