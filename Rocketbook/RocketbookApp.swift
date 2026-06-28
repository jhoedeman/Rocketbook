import SwiftUI

@main
struct RocketbookApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.theme, themeManager.activeTheme)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)  // remove when light mode support is added
        }
    }
}
