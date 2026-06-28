import Foundation

@MainActor
final class RocketListViewModel: ObservableObject {
    @Published var groupedRockets: [(family: String, rockets: [RocketConfig])] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = SpaceAPIClient.shared
    private let cache = CacheStore.rocketList

    func load() async {
        if let cached = cache.load() {
            groupedRockets = group(cached)
            refreshInBackground()
            return
        }
        await fetch()
    }

    private func refreshInBackground() {
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await fetch(silent: true)
        }
    }

    private func fetch(silent: Bool = false) async {
        if !silent { isLoading = true }
        defer { if !silent { isLoading = false } }
        do {
            let rockets = try await api.fetchAllRocketConfigs()
            cache.save(rockets)
            groupedRockets = group(rockets)
            error = nil
        } catch {
            if !silent { self.error = error.localizedDescription }
        }
    }

    private func group(_ rockets: [RocketConfig]) -> [(family: String, rockets: [RocketConfig])] {
        let families = Dictionary(grouping: rockets) { $0.family }
        return families
            .map { (family: $0.key, rockets: $0.value.sorted { $0.name < $1.name }) }
            .sorted { $0.family < $1.family }
    }
}
