//
//  MyLaunchesViewModel.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import Foundation
import Combine

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

        let allRockets = rocketCache.load() ?? []
        let tracked = allRockets.filter { subscribedIDs.contains($0.id) }

        // Capture api before entering task group to avoid @MainActor cross-actor access
        let api = self.api
        var results: [Item] = []

        await withTaskGroup(of: Item.self) { group in
            for rocket in tracked {
                let rocketID = rocket.id
                group.addTask {
                    let cache = await CacheStore.upcomingLaunch(rocketID: rocketID)
                    let next: Launch?
                    if let cached = await cache.load() {
                        next = cached
                    } else {
                        next = try? await api.fetchUpcomingLaunch(rocketConfigID: rocketID)
                    }
                    return Item(rocket: rocket, nextLaunch: next)
                }
            }
            for await item in group { results.append(item) }
        }
        items = results.sorted { $0.rocket.name < $1.rocket.name }
    }
}
