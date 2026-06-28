import Foundation

struct DiskCache<Value: Codable> {
    private let filename: String
    private let ttl: TimeInterval
    private let fileURL: URL

    init(filename: String, ttl: TimeInterval) {
        self.filename = filename
        self.ttl = ttl
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.fileURL = dir.appendingPathComponent("\(filename).cache")
    }

    func save(_ value: Value) {
        let envelope = Envelope(value: value, savedAt: Date())
        guard let data = try? JSONEncoder().encode(envelope) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func load() -> Value? {
        guard
            let data = try? Data(contentsOf: fileURL),
            let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
            Date().timeIntervalSince(envelope.savedAt) < ttl
        else { return nil }
        return envelope.value
    }

    func invalidate() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    private struct Envelope: Codable {
        let value: Value
        let savedAt: Date
    }
}

enum CacheStore {
    static let rocketList  = DiskCache<[RocketConfig]>(filename: "rocket_list",    ttl: 86_400)  // 24 h
    static func flightHistory(rocketID: Int) -> DiskCache<[Launch]> {
        DiskCache(filename: "history_\(rocketID)", ttl: 21_600)                                  // 6 h
    }
    static func upcomingLaunch(rocketID: Int) -> DiskCache<Launch?> {
        DiskCache(filename: "upcoming_\(rocketID)", ttl: 300)                                    // 5 min; always refreshed on foreground
    }
}
