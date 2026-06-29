//
//  RocketListViewModel.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import Foundation
import Combine

@MainActor
final class RocketListViewModel: ObservableObject {
    @Published var selectedFamily: String = "All"
    @Published private(set) var allGrouped: [(family: String, rockets: [RocketConfig])] = []
    @Published var isLoading = false
    @Published var error: String?

    var familyNames: [String] {
        ["All"] + allGrouped.map(\.family)
    }

    var groupedRockets: [(family: String, rockets: [RocketConfig])] {
        guard selectedFamily != "All" else { return allGrouped }
        return allGrouped.filter { $0.family == selectedFamily }
    }

    private let api = SpaceAPIClient.shared
    private let cache = CacheStore.rocketList

    func load() async {
        if let cached = cache.load() {
            allGrouped = group(cached)
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
            allGrouped = group(rockets)
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
