//
//  ContentView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        TabView {
            RocketListView()
                .tabItem {
                    Label("Rockets", systemImage: "airplane")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
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
