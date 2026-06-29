//
//  LaunchStatusBadge.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct LaunchStatusBadge: View {
    let status: LaunchStatus?
    @Environment(\.theme) private var theme

    var body: some View {
        if let abbrev = status?.abbrev {
            Text(abbrev)
                .font(.caption2.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(color(for: abbrev).opacity(0.2))
                .foregroundStyle(color(for: abbrev))
                .clipShape(Capsule())
        }
    }

    private func color(for abbrev: String) -> Color {
        switch abbrev {
        case "Success": return theme.success
        case "Failure", "Partial Failure": return theme.destructive
        default: return theme.secondaryText
        }
    }
}
