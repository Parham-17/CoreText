import SwiftUI

struct SummaryCardView: View {
    let summary: AttributedString
    let tone: SummaryTone
    let originalText: String

    let onNewSession: () -> Void
    let onExpand: () -> Void

    private var tint: Color {
        switch tone {
        case .balanced:     return .blue
        case .scientific:   return .red
        case .concise:      return .cyan
        case .creative:     return .purple
        case .bulletPoints: return .green
        }
    }

    private var plainSummaryPrefix: String {
        let s = String(summary.characters)
        let trimmed = s.replacingOccurrences(of: "\n", with: " ")
        return String(trimmed.prefix(120))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Summary")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Expand button
                Button {
                    onExpand()
                    Haptics.impact(.light)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                        Text("Expand")
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.7)
                    )
                }
                .accessibilityLabel("Show summary full screen")
                .accessibilityHint("Opens the summary in a larger view with extra options like text to speech.")
            }

            Text(summary)
                .lineLimit(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
                .accessibilityLabel("Summary: \(plainSummaryPrefix)")

            HStack {
                // Tone info
                Label(tone.displayName, systemImage: "slider.horizontal.3")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                // New session / clear
                Button {
                    onNewSession()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("New session")
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.7)
                    )
                }
                .accessibilityLabel("New session")
                .accessibilityHint("Clears the summary and input so you can start over with new text.")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .accessibilityElement(children: .contain)
        .accessibilityHint("Contains your latest summary, with options to expand or start a new session.")
    }
}
