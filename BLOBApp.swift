import SwiftUI

@main
struct ReipilogoApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)   // ⬅️ Always use dark mode
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)           // ⬅️ Also force dark in previews
}
