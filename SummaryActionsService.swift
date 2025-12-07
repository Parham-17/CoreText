import Foundation
import UIKit

/// Handles side effects related to summary output:
/// - Copying to clipboard
/// - Exporting to files
/// - Playing related haptics
final class SummaryActionsService {

    /// Copy plain text to the clipboard and play a success haptic.
    func copyPlainText(_ text: String) {
        UIPasteboard.general.string = text
        Haptics.notify(.success)
    }

    /// Export text to a temporary file with the given extension.
    /// Returns a `FileExportItem` if successful, or nil otherwise.
    func exportFile(for text: String, ext: String) -> FileExportItem? {
        guard let url = SummaryFileExporter.makeFile(with: text, ext: ext) else {
            return nil
        }
        Haptics.notify(.success)
        return FileExportItem(url: url)
    }
}
