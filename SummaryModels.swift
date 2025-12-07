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

    /// Instruction you pass to the FM.
    var systemInstruction: String {
        switch self {
        case .balanced:
            return """
            Write a clear, natural summary with a neutral tone.
            Keep all key points but avoid being too long or too short.
            """
        case .scientific:
            return """
            Write a precise, formal summary using scientific or academic language.
            Emphasize definitions, data, and logical structure. Avoid jokes and slang.
            """
        case .concise:
            return """
            Write the shortest possible summary that still preserves the core meaning.
            Avoid extra adjectives, examples, or side notes. Prioritize brevity.
            """
        case .creative:
            return """
            Write an engaging, narrative-style summary with a friendly tone and light storytelling,
            while keeping the main facts accurate. You can use metaphors or imagery.
            """
        case .bulletPoints:
            return """
            Write the summary as a list of structured bullet points.
            Group related ideas under clear bullets or sub-bullets.
            Avoid long paragraphs and focus on structure.
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
        case .asFile:      return "Export a document you can share or store."
        case .asPlainText: return "Copy the summary to the clipboard."
        case .asMarkdown:  return "Keep headings, lists and formatting."
        }
    }

    var systemImage: String {
        switch self {
        case .asFile:      return "doc.badge.arrow.down"
        case .asPlainText: return "doc.on.doc"
        case .asMarkdown:  return "number"
        }
    }
}
