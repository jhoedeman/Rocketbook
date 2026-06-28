import Foundation

struct Launch: Codable, Identifiable {
    let id: String
    let name: String
    let net: Date?
    let windowStart: Date?
    let windowEnd: Date?
    let status: LaunchStatus?
    let pad: Pad?
    let mission: Mission?
    let image: String?
    let webcastLive: Bool?
    let probability: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, status, pad, mission, image, probability
        case net
        case windowStart = "window_start"
        case windowEnd = "window_end"
        case webcastLive = "webcast_live"
    }
}

struct LaunchStatus: Codable {
    let id: Int
    let name: String
    let abbrev: String
    let description: String?
}

struct Pad: Codable {
    let id: Int
    let name: String
    let location: PadLocation?
}

struct PadLocation: Codable {
    let id: Int
    let name: String
    let countryCode: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case countryCode = "country_code"
    }
}

struct Mission: Codable {
    let id: Int?
    let name: String
    let description: String?
    let type: String?
    let orbit: Orbit?
}

struct Orbit: Codable {
    let id: Int
    let name: String
    let abbrev: String
}

extension Launch {
    /// True for launches that succeeded (status abbrev "Success")
    var succeeded: Bool { status?.abbrev == "Success" }
    /// True for launches that failed
    var failed: Bool { status?.abbrev == "Failure" }
}
