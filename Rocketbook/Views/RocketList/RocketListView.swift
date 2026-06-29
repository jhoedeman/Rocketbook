//
//  RocketListView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct RocketListView: View {
    @StateObject private var vm = RocketListViewModel()
    @ObservedObject private var favorites = FavoritesManager.shared
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.allGrouped.isEmpty {
                    ProgressView("Loading rockets…")
                        .foregroundStyle(theme.secondaryText)
                } else if let error = vm.error, vm.allGrouped.isEmpty {
                    ContentUnavailableView("Failed to load", systemImage: "wifi.slash", description: Text(error))
                } else {
                    List {
                        ForEach(vm.groupedRockets, id: \.family) { group in
                            Section(group.family) {
                                ForEach(group.rockets) { rocket in
                                    NavigationLink(destination: RocketDetailView(rocket: rocket)) {
                                        RocketRowView(rocket: rocket, isFavorite: favorites.isFavorite(rocket)) {
                                            favorites.toggle(rocket)
                                        }
                                    }
                                    .listRowBackground(theme.surface)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(theme.background)
                }
            }
            .navigationTitle("Rocket Families")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Family", selection: $vm.selectedFamily) {
                            ForEach(vm.familyNames, id: \.self) { family in
                                Text(family).tag(family)
                            }
                        }
                    } label: {
                        Label(
                            vm.selectedFamily == "All" ? "Filter" : vm.selectedFamily,
                            systemImage: vm.selectedFamily == "All" ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"
                        )
                        .foregroundStyle(vm.selectedFamily == "All" ? theme.secondaryText : theme.accent)
                    }
                }
            }
        }
        .task { await vm.load() }
    }
}

private struct RocketRowView: View {
    let rocket: RocketConfig
    let isFavorite: Bool
    let onStar: () -> Void
    @Environment(\.theme) private var theme

    var body: some View {
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

            Spacer()

            if rocket.reusable == true {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(theme.accent)
            }

            Button {
                onStar()
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(isFavorite ? theme.accent : theme.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
