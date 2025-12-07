import SwiftUI

// Wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) { }
}

// Identifiable file export payload
struct FileExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

// Helper to write a temp file for export
enum SummaryFileExporter {
    static func makeFile(with text: String, ext: String) -> URL? {
        let filename = "Summary-\(UUID().uuidString.prefix(5)).\(ext)"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try text.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            print("ERROR writing summary file:", error)
            return nil
        }
    }
}
