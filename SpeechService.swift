import AVFoundation

/// Shared text-to-speech helper for reading summaries aloud.
final class SpeechService {

    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    func speak(_ text: String) {
        // Stop any ongoing speech immediately
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.prefersAssistiveTechnologySettings = true   // respect accessibility

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
