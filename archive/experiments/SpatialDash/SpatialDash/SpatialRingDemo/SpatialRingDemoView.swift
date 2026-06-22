import SwiftUI

struct SpatialRingDemoView: View {
    @State private var progress = 0.35

    var body: some View {
        VStack(spacing: 20) {
            TorusRingSceneView(progress: progress)
                .frame(minHeight: 420)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .blue.opacity(0.22), radius: 28, y: 12)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Timer progress")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Slider(value: $progress, in: 0...1)
                    .tint(.cyan)

                Text("The visible arc represents remaining activity.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("3D Ring Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
}
