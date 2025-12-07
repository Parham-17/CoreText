import SwiftUI

enum ExportSheetData: Identifiable {
    case text(String)

    var id: String {
        switch self {
        case .text: return "text"
        }
    }
}

struct SaveManager {
    static func textFile(for content: String) -> URL? {
        let filename = "Summary-\(UUID().uuidString.prefix(5)).txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try content.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            print("ERROR writing file:", error)
            return nil
        }
    }
}
