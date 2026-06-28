import SwiftUI

struct RocketListView: View {
    @StateObject private var vm = RocketListViewModel()
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.groupedRockets.isEmpty {
                    ProgressView("Loading rockets…")
                        .foregroundStyle(theme.secondaryText)
                } else if let error = vm.error, vm.groupedRockets.isEmpty {
                    ContentUnavailableView("Failed to load", systemImage: "wifi.slash", description: Text(error))
                } else {
                    List {
                        ForEach(vm.groupedRockets, id: \.family) { group in
                            Section(group.family) {
                                ForEach(group.rockets) { rocket in
                                    NavigationLink(destination: RocketDetailView(rocket: rocket)) {
                                        RocketRowView(rocket: rocket)
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
        }
        .task { await vm.load() }
    }
}

private struct RocketRowView: View {
    let rocket: RocketConfig
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
        }
        .padding(.vertical, 4)
    }
}
