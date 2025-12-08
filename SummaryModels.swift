import Foundation

// MARK: - Summary style / tone for the foundation model

enum SummaryTone: String, CaseIterable, Identifiable {
    case balanced
    case scientific
    case concise
    case creative
    case bulletPoints

    var id: Self { self }

    var displayName: String {
        switch self {
        case .balanced:      return "Balanced"
        case .scientific:    return "Scientific"
        case .concise:       return "Concise"
        case .creative:      return "Creative"
        case .bulletPoints:  return "Bullet points"
        }
    }

    /// Instruction you pass to the FM for this tone.
    ///
    /// These are designed so:
    /// - Scientific keeps mechanisms, methods, abbreviations, limitations.
    /// - Balanced keeps seriousness and structure but is readable.
    /// - Concise is ultra-short but keeps all distinct ideas.
    /// - Creative keeps emotional tone and narrative flavor.
    /// - Bullet points is clean, one-idea-per-bullet structure.
    var systemInstruction: String {
        switch self {
        case .balanced:
            return """
            Write a clear, neutral summary that preserves all important facts \
            and the seriousness of any risks, ethical dilemmas, or emotional stakes. \
            Do not oversimplify. Keep the main structure of the original argument while \
            making it easier to read.
            """

        case .scientific:
            return """
            Write a precise, formal summary using scientific or academic language. \
            Preserve mechanistic details, key definitions, abbreviations, methods, \
            biomarkers, and limitations. Highlight the main findings and any open questions. \
            Avoid jokes, slang, or casual tone.
            """

        case .concise:
            return """
            Write the shortest possible summary that still preserves all distinct ideas \
            and concerns. Remove examples, repetition, and minor details, but do not drop \
            entire categories of meaning. Prioritize brevity over style.
            """

        case .creative:
            return """
            Write an engaging, narrative-style summary that keeps the emotional tone \
            and personality of the original text. You may lightly rephrase for flow, \
            but keep all important facts accurate and do not invent new events or details.
            """

        case .bulletPoints:
            return """
            Write the summary as a list of structured bullet points. \
            Each bullet should contain one key idea. \
            Preserve important technical, ethical, or emotional nuances. \
            Do not write long paragraphs.
            """
        }
    }
}

// MARK: - Save actions shown in the menu

enum SaveAction: String, CaseIterable, Identifiable {
    case asFile
    case asPlainText
    case asMarkdown

    var id: Self { self }

    var title: String {
        switch self {
        case .asFile:      return "Save as file"
        case .asPlainText: return "Copy as text"
        case .asMarkdown:  return "Save as Markdown"
        }
    }

    var subtitle: String {
        switch self {
        case .asFile:
            return "Export a document you can share or store."
        case .asPlainText:
            return "Copy the summary to the clipboard."
        case .asMarkdown:
            return "Keep headings, lists and formatting."
        }
    }

    var systemImage: String {
        switch self {
        case .asFile:
            // Safe SF Symbol that exists everywhere.
            return "square.and.arrow.down"
        case .asPlainText:
            return "doc.on.doc"
        case .asMarkdown:
            return "number"
        }
    }
}
