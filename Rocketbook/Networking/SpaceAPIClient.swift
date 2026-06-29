//
//  SpaceAPIClient.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import Foundation

enum APIError: Error {
    case badURL
    case network(Error)
    case decoding(Error)
    case server(Int)
}

final class SpaceAPIClient {
    static let shared = SpaceAPIClient()

    private let base = URL(string: "https://ll.thespacedevs.com/2.2.0")!
    private let session: URLSession

    private lazy var decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let str = try decoder.singleValueContainer().decode(String.self)
            if let date = fmt.date(from: str) { return date }
            // fallback without fractional seconds
            let fmt2 = ISO8601DateFormatter()
            if let date = fmt2.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Cannot parse date: \(str)"
            )
        }
        return d
    }()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    func fetchRocketConfigs(page: Int = 1) async throws -> PaginatedResponse<RocketConfig> {
        var comps = URLComponents(url: base.appendingPathComponent("/config/launcher/"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "offset", value: "\((page - 1) * 100)"),
            URLQueryItem(name: "ordering", value: "name"),
            URLQueryItem(name: "mode", value: "detailed")
        ]
        return try await fetch(comps.url!)
    }

    func fetchAllRocketConfigs() async throws -> [RocketConfig] {
        var all: [RocketConfig] = []
        var page = 1
        while true {
            let response = try await fetchRocketConfigs(page: page)
            all.append(contentsOf: response.results)
            if response.next == nil { break }
            page += 1
        }
        return all
    }

    func fetchUpcomingLaunch(rocketConfigID: Int) async throws -> Launch? {
        var comps = URLComponents(url: base.appendingPathComponent("/launch/upcoming/"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "rocket__configuration__id", value: "\(rocketConfigID)"),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "ordering", value: "net")
        ]
        let response: PaginatedResponse<Launch> = try await fetch(comps.url!)
        return response.results.first
    }

    func fetchPreviousLaunches(rocketConfigID: Int, limit: Int = 30) async throws -> [Launch] {
        var comps = URLComponents(url: base.appendingPathComponent("/launch/previous/"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "rocket__configuration__id", value: "\(rocketConfigID)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "ordering", value: "-net")
        ]
        let response: PaginatedResponse<Launch> = try await fetch(comps.url!)
        return response.results
    }

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.server(http.statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
