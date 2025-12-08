import SwiftUI

struct SummaryCardView: View {
    let summary: AttributedString
    let tone: SummaryTone
    let originalText: String

    let onNewSession: () -> Void
    let onExpand: () -> Void

    // MARK: - Word counts

    private var originalWordCount: Int {
        originalText
            .split { $0.isWhitespace || $0.isNewline }
            .count
    }

    private var summaryWordCount: Int {
        String(summary.characters)
            .split { $0.isWhitespace || $0.isNewline }
            .count
    }

    var body: some View {
        ZStack {
            // MARK: Glass background (no big white sheet anymore)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial) // native glass
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1) // subtle edge
                )

            // MARK: Content inside the glass
            VStack(alignment: .leading, spacing: 10) {

                // Header: title + Expand
                HStack {
                    Text("Summary")
                        .font(.headline.weight(.semibold))

                    Spacer()

                    Button(action: onExpand) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                            Text("Expand")
                        }
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        )
                    }
                    .tint(.blue)
                    .accessibilityLabel("Expand summary")
                    .accessibilityHint("Show the summary full screen with extra options.")
                }

                // Word counts
                if !originalText.isEmpty {
                    HStack {
                        Spacer()
                        Text("\(originalWordCount) → \(summaryWordCount) words")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Scrollable summary text
                ScrollView {
                    Text(summary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                        .foregroundStyle(.primary)
                }
                .scrollIndicators(.visible)

                // Footer: tone caption + New session
                HStack {
                    // 👉 Tone as caption (not a button / chip)
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(tone.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Tone: \(tone.displayName)")

                    Spacer()

                    Button(action: onNewSession) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("New session")
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        )
                    }
                    .tint(.blue)
                    .accessibilityLabel("New session")
                    .accessibilityHint("Clear the current summary and start again.")
                }
            }
            .padding(16)
        }
        // Same overall size / position as before
        .frame(minHeight: 300, maxHeight: 400)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }
}
