import SwiftUI

public struct TimeBiteRootView: View {
    public init() {}
    public var body: some View {
        NavigationStack {
            List {
                Section("Experimental") {
                    NavigationLink {
                        SpatialRingDemoView()
                    } label: {
                        Label("3D Ring Demo", systemImage: "circle.hexagongrid.circle")
                    }
                }

                Section("Placeholder") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TimeBite Root View")
                            .font(.headline)
                        Text("Temporary shell for testing isolated prototype screens.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("SpatialDash")
        }
    }
}
