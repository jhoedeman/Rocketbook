//
//  FavoritesView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/29/26.
//

import Foundation
import Combine

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    @Published private(set) var favoriteIDs: Set<Int>

    private let defaults = UserDefaults.standard
    private let key = "favoriteRocketIDs"

    private init() {
        let arr = defaults.array(forKey: key) as? [Int] ?? []
        self.favoriteIDs = Set(arr)
    }

    func isFavorite(_ rocket: RocketConfig) -> Bool {
        favoriteIDs.contains(rocket.id)
    }

    func toggle(_ rocket: RocketConfig) {
        if favoriteIDs.contains(rocket.id) {
            favoriteIDs.remove(rocket.id)
        } else {
            favoriteIDs.insert(rocket.id)
        }
        defaults.set(Array(favoriteIDs), forKey: key)
    }
}
