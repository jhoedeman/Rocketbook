//
//  RocketConfig.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import Foundation

struct RocketConfig: Codable, Identifiable, Hashable {
    let id: Int
    let url: String
    let name: String
    let fullName: String?
    let family: String
    let variant: String?
    let imageUrl: String?
    let wikiUrl: String?
    let infoUrl: String?
    let manufacturer: Agency?
    let reusable: Bool?

    enum CodingKeys: String, CodingKey {
        case id, url, name, family, variant
        case fullName = "full_name"
        case imageUrl = "image_url"
        case wikiUrl = "wiki_url"
        case infoUrl = "info_url"
        case manufacturer
        case reusable
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: RocketConfig, rhs: RocketConfig) -> Bool { lhs.id == rhs.id }
}

struct Agency: Codable {
    let id: Int?
    let name: String
    let countryCode: String?
    let description: String?
    let logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case countryCode = "country_code"
        case logoUrl = "logo_url"
    }
}

struct PaginatedResponse<T: Codable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
