//
//  NotificationManager.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let subscribedKey = "subscribedRocketIDs"

    private init() {}

    // MARK: - Permission

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Subscription state

    var subscribedIDs: Set<Int> {
        get {
            let arr = defaults.array(forKey: subscribedKey) as? [Int] ?? []
            return Set(arr)
        }
        set {
            defaults.set(Array(newValue), forKey: subscribedKey)
        }
    }

    func isSubscribed(to rocketID: Int) -> Bool {
        subscribedIDs.contains(rocketID)
    }

    // MARK: - Toggle

    func toggle(rocketID: Int, nextLaunch: Launch?) async {
        if isSubscribed(to: rocketID) {
            unsubscribe(rocketID: rocketID)
        } else {
            let granted = await requestAuthorization()
            guard granted else { return }
            subscribe(rocketID: rocketID, nextLaunch: nextLaunch)
        }
    }

    // MARK: - Schedule

    func subscribe(rocketID: Int, nextLaunch: Launch?) {
        var ids = subscribedIDs
        ids.insert(rocketID)
        subscribedIDs = ids
        if let launch = nextLaunch {
            scheduleNotifications(for: launch, rocketID: rocketID)
        }
    }

    func unsubscribe(rocketID: Int) {
        var ids = subscribedIDs
        ids.remove(rocketID)
        subscribedIDs = ids
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs(rocketID: rocketID))
    }

    func refreshNotifications(rocketID: Int, nextLaunch: Launch?) {
        guard isSubscribed(to: rocketID) else { return }
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs(rocketID: rocketID))
        if let launch = nextLaunch {
            scheduleNotifications(for: launch, rocketID: rocketID)
        }
    }

    // MARK: - Private

    private func scheduleNotifications(for launch: Launch, rocketID: Int) {
        guard let net = launch.net else { return }

        let offsets: [(String, TimeInterval)] = [
            ("24h", -86_400),
            ("1h",  -3_600)
        ]

        for (label, offset) in offsets {
            let fireDate = net.addingTimeInterval(offset)
            guard fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = launch.name
            content.body  = label == "24h"
                ? "Launches in 24 hours"
                : "Launching in 1 hour — webcast may be live soon"
            content.sound = .default

            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let id = "\(rocketID)_\(label)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    private func notificationIDs(rocketID: Int) -> [String] {
        ["\(rocketID)_24h", "\(rocketID)_1h"]
    }
}
