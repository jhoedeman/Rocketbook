import SwiftUI

struct ContentView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        TabView {
            RocketListView()
                .tabItem {
                    Label("Rockets", systemImage: "rocket")
                }

            MyLaunchesView()
                .tabItem {
                    Label("My Launches", systemImage: "bell")
                }
        }
        .tint(theme.accent)
        .background(theme.background)
    }
}
