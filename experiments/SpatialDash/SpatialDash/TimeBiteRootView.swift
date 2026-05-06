import SwiftUI

public struct TimeBiteRootView: View {
    public init() {}
    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "clock")
                    .font(.system(size: 48, weight: .regular))
                Text("TimeBite Root View")
                    .font(.title2)
                    .bold()
                Text("Replace this placeholder with your real root view.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("SpatialDash")
        }
    }
}

#Preview {
    TimeBiteRootView()
}
