//
//  FavoritesView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var favorites = FavoritesManager.shared
    @Environment(\.theme) private var theme

    private var favoriteRockets: [RocketConfig] {
        let cached = CacheStore.rocketList.load() ?? []
        return cached
            .filter { favorites.isFavorite($0) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteRockets.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "star",
                        description: Text("Tap the star on any rocket to save it here")
                    )
                } else {
                    List(favoriteRockets) { rocket in
                        NavigationLink(destination: RocketDetailView(rocket: rocket)) {
                            HStack(spacing: 12) {
                                AsyncImageView(urlString: rocket.imageUrl, contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(rocket.name)
                                        .font(.headline)
                                        .foregroundStyle(theme.primaryText)
                                    if let manufacturer = rocket.manufacturer?.name {
                                        Text(manufacturer)
                                            .font(.caption)
                                            .foregroundStyle(theme.secondaryText)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(theme.surface)
                    }
                    .scrollContentBackground(.hidden)
                    .background(theme.background)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
