import SwiftUI

struct RocketDetailView: View {
    let rocket: RocketConfig
    @StateObject private var vm: RocketDetailViewModel
    @Environment(\.theme) private var theme

    init(rocket: RocketConfig) {
        self.rocket = rocket
        _vm = StateObject(wrappedValue: RocketDetailViewModel(rocket: rocket))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    nextLaunchSection
                    flightHistorySection
                }
                .padding()
            }
        }
        .background(theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await vm.refreshOnForeground() }
        }
    }

    // MARK: - Hero

    private var heroImage: some View {
        AsyncImageView(urlString: rocket.imageUrl, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .clipped()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rocket.fullName ?? rocket.name)
                        .font(.title2.bold())
                        .foregroundStyle(theme.primaryText)
                    if let manufacturer = rocket.manufacturer?.name {
                        Text(manufacturer)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }
                }
                Spacer()
                if rocket.reusable == true {
                    Label("Reusable", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accent.opacity(0.15))
                        .foregroundStyle(theme.accent)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                if let wiki = rocket.wikiUrl, let url = URL(string: wiki) {
                    Link(destination: url) {
                        Label("Wikipedia", systemImage: "w.circle")
                            .font(.caption)
                            .foregroundStyle(theme.accent)
                    }
                }
                if let info = rocket.infoUrl, let url = URL(string: info) {
                    Link(destination: url) {
                        Label("More info", systemImage: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(theme.accent)
                    }
                }
            }
        }
    }

    // MARK: - Next Launch

    private var nextLaunchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Next Launch")
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Button {
                    Task { await vm.toggleNotification() }
                } label: {
                    Image(systemName: vm.isSubscribed ? "bell.fill" : "bell")
                        .foregroundStyle(vm.isSubscribed ? theme.accent : theme.secondaryText)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            if vm.isLoadingNext {
                ProgressView().frame(maxWidth: .infinity)
            } else if let launch = vm.nextLaunch, let net = launch.net {
                VStack(alignment: .leading, spacing: 10) {
                    Text(launch.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(theme.primaryText)

                    if let pad = launch.pad {
                        Label(pad.name, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                    }

                    CountdownView(target: net)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
                .padding()
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("No upcoming launches scheduled")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Flight History

    private var flightHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flight History")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            if vm.isLoadingHistory {
                ProgressView().frame(maxWidth: .infinity)
            } else if vm.pastLaunches.isEmpty {
                Text("No recorded flights")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            } else {
                VStack(spacing: 1) {
                    ForEach(vm.pastLaunches) { launch in
                        LaunchHistoryRow(launch: launch)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private struct LaunchHistoryRow: View {
    let launch: Launch
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(urlString: launch.image, contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 3) {
                Text(launch.name)
                    .font(.subheadline)
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                if let net = launch.net {
                    Text(net, style: .date)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
            }

            Spacer()
            LaunchStatusBadge(status: launch.status)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.surface)
    }
}
