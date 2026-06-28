import Foundation

@MainActor
final class MyLaunchesViewModel: ObservableObject {
    struct Item: Identifiable {
        let rocket: RocketConfig
        let nextLaunch: Launch?
        var id: Int { rocket.id }
    }

    @Published var items: [Item] = []
    @Published var isLoading = false

    private let api = SpaceAPIClient.shared
    private let notifications = NotificationManager.shared
    private let rocketCache = CacheStore.rocketList

    func load() async {
        let subscribedIDs = notifications.subscribedIDs
        guard !subscribedIDs.isEmpty else {
            items = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        // Pull rocket configs from disk cache (already fetched by RocketListView)
        let allRockets = rocketCache.load() ?? []
        let tracked = allRockets.filter { subscribedIDs.contains($0.id) }

        // Fetch upcoming launches in parallel
        await withTaskGroup(of: Item.self) { group in
            for rocket in tracked {
                group.addTask {
                    let cache = CacheStore.upcomingLaunch(rocketID: rocket.id)
                    let next = cache.load() ?? (try? await self.api.fetchUpcomingLaunch(rocketConfigID: rocket.id))
                    return Item(rocket: rocket, nextLaunch: next ?? nil)
                }
            }
            var results: [Item] = []
            for await item in group { results.append(item) }
            items = results.sorted { $0.rocket.name < $1.rocket.name }
        }
    }
}
