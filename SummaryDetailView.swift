import SwiftUI

struct SummaryDetailView: View {
    let summary: AttributedString
    let tone: SummaryTone

    @Environment(\.dismiss) private var dismiss
    @StateObject private var speech = SpeechService()
    @State private var showSpeechAlert: Bool = false

    private var plainText: String {
        String(summary.characters)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Tone label
                    Text(tone.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    // Actual summary text
                    Text(summary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                }
                .padding(20)
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // Close
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        speech.stop()
                        dismiss()
                    }
                }

                // Text-to-speech button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSpeechAlert = true
                    } label: {
                        Image(
                            systemName: speech.isSpeaking
                            ? "speaker.wave.2.fill"
                            : "speaker.wave.1"
                        )
                    }
                    .accessibilityLabel(
                        speech.isSpeaking
                        ? "Stop reading summary"
                        : "Read summary aloud"
                    )
                }
            }
        }
        .alert("Read this summary aloud?",
               isPresented: $showSpeechAlert) {
            Button("Read aloud") {
                speech.read(text: plainText)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Audio can be heard by people nearby. Make sure you’re comfortable before playing it out loud.")
        }
        .onDisappear {
            speech.stop()
        }
    }
}
