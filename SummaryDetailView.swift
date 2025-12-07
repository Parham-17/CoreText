import SwiftUI

struct SummaryDetailView: View {
    let summary: AttributedString
    let tone: SummaryTone

    @Environment(\.dismiss) private var dismiss
    private let speech = SpeechService.shared

    @State private var showSpeakConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    Text(summary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .foregroundColor(.primary)
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .padding(.horizontal, 16)
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Close
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close full summary")
                }

                // Text-to-speech
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // security/privacy prompt first
                        showSpeakConfirm = true
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .tint(colorForTone(tone))
                    .accessibilityLabel("Read summary out loud")
                    .accessibilityHint("Plays the summary with device speech, which may expose private information if others can hear.")
                }
            }
            .alert(
                "Read this summary out loud?",
                isPresented: $showSpeakConfirm
            ) {
                Button("Cancel", role: .cancel) { }

                Button("Read aloud") {
                    let text = String(summary.characters)
                    speech.speak(text)
                    Haptics.notify(.success)
                }
            } message: {
                Text("This summary may contain sensitive or private information. Make sure you're in a place where it's safe for it to be spoken aloud.")
            }
        }
    }

    private func colorForTone(_ tone: SummaryTone) -> Color {
        switch tone {
        case .balanced:     return .blue
        case .scientific:   return .red
        case .concise:      return .cyan
        case .creative:     return .purple
        case .bulletPoints: return .green
        }
    }
}
