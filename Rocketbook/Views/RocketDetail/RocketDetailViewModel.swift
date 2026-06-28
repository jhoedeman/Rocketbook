import Foundation

@MainActor
final class RocketDetailViewModel: ObservableObject {
    let rocket: RocketConfig

    @Published var nextLaunch: Launch?
    @Published var pastLaunches: [Launch] = []
    @Published var isLoadingNext = false
    @Published var isLoadingHistory = false
    @Published var isSubscribed = false

    private let api = SpaceAPIClient.shared
    private let notifications = NotificationManager.shared

    init(rocket: RocketConfig) {
        self.rocket = rocket
    }

    func load() async {
        isSubscribed = notifications.isSubscribed(to: rocket.id)
        async let next: () = loadNextLaunch()
        async let history: () = loadHistory()
        _ = await (next, history)
    }

    func toggleNotification() async {
        await notifications.toggle(rocketID: rocket.id, nextLaunch: nextLaunch)
        isSubscribed = notifications.isSubscribed(to: rocket.id)
    }

    func refreshOnForeground() async {
        await loadNextLaunch(bustCache: true)
        notifications.refreshNotifications(rocketID: rocket.id, nextLaunch: nextLaunch)
    }

    // MARK: - Private

    private func loadNextLaunch(bustCache: Bool = false) async {
        let cache = CacheStore.upcomingLaunch(rocketID: rocket.id)
        if !bustCache, let cached = cache.load() {
            nextLaunch = cached
            return
        }
        isLoadingNext = true
        defer { isLoadingNext = false }
        do {
            let launch = try await api.fetchUpcomingLaunch(rocketConfigID: rocket.id)
            cache.save(launch)
            nextLaunch = launch
        } catch {
            // keep stale value if available
        }
    }

    private func loadHistory() async {
        let cache = CacheStore.flightHistory(rocketID: rocket.id)
        if let cached = cache.load() {
            pastLaunches = cached
            return
        }
        isLoadingHistory = true
        defer { isLoadingHistory = false }
        do {
            let launches = try await api.fetchPreviousLaunches(rocketConfigID: rocket.id)
            cache.save(launches)
            pastLaunches = launches
        } catch {}
    }
}
