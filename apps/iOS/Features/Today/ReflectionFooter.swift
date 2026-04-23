import SwiftUI

public struct ReflectionFooter: View {
    @Binding var text: String

    public init(text: Binding<String>) {
        _text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Did I move the needle today?")
                .font(.headline)

            TextField("One sentence. No guilt.", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(2, reservesSpace: true)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .accessibilityElement(children: .contain)
    }
}

struct ReflectionFooter_Previews: PreviewProvider {
    static var previews: some View {
        Wrapper()
    }

    private struct Wrapper: View {
        @State var text: String = ""
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                ReflectionFooter(text: $text)
                    .padding()
            }
            .preferredColorScheme(.dark)
        }
    }
}
