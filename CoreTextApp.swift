import SwiftUI

@main
struct CoreTextApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)   // Always dark mode
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
