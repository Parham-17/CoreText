import SwiftUI

struct SummaryDetailView: View {
    let summary: AttributedString
    let tone: SummaryTone

    @StateObject private var speech = SpeechService()
    @State private var showSpeechAlert: Bool = false

    private var plainText: String {
        String(summary.characters)
    }

    private var wordCount: Int {
        plainText
            .split { $0.isWhitespace || $0.isNewline }
            .count
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Glass container – like the card, but bigger
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1.1)
                            )
                            .shadow(radius: 24)

                        VStack(alignment: .leading, spacing: 16) {

                            // Header
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 6) {
                                   HStack(spacing: 10) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "slider.horizontal.3")
                                                .font(.caption2)
                                            Text(tone.displayName)
                                                .font(.caption)
                                        }
                                        .foregroundStyle(.secondary)

                                        Divider()
                                            .frame(height: 10)

                                        Text("\(wordCount) words")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }

                            // Summary text
                            Text(summary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .padding(.top, 4)
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Spacer(minLength: 20)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            // Center title – system back button stays on the left
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "text.justify.left")
                        .font(.subheadline)
                    Text("Summary")
                        .font(.headline.weight(.semibold))
                }
            }

            // Top-right: TTS button only
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    ttsButtonTapped()
                } label: {
                    Image(systemName: speech.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.1")
                        .symbolRenderingMode(.hierarchical)
                }
                .tint(.white)
                .accessibilityLabel(
                    speech.isSpeaking ? "Stop reading summary" : "Read summary aloud"
                )
            }
        }
        .alert(
            "Read this summary aloud?",
            isPresented: $showSpeechAlert
        ) {
            Button("Cancel", role: .cancel) { }

            Button("Read aloud") {
                if speech.isSpeaking {
                    speech.stop()
                }
                speech.read(plainText)   // ← your original call
            }
        } message: {
            Text("Audio can be heard by people nearby. Make sure you're comfortable before playing it out loud.")
        }
        .onDisappear {
            speech.stop()
        }
    }

    private func ttsButtonTapped() {
        if speech.isSpeaking {
            speech.stop()
        } else {
            showSpeechAlert = true
        }
    }
}
