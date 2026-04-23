import SwiftUI

public struct KillListCard: View {
    let items: [String]

    public init(items: [String]) {
        self.items = items
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Kill List")
                    .font(.headline)
                Spacer()
                Image(systemName: "nosign")
                    .foregroundStyle(.secondary)
            }

            Text("Avoid today:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 10) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .commandCenterCard()
    }
}

struct KillListCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            KillListCard(items: ["Redesign site", "Random new features", "Tool hopping"])
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}
