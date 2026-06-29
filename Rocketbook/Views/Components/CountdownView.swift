//
//  CountdownView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI
import Combine

struct CountdownView: View {
    let target: Date
    @Environment(\.theme) private var theme
    @State private var remaining: DateComponents = DateComponents()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 16) {
            unit(value: remaining.day ?? 0,    label: "DAYS")
            separator
            unit(value: remaining.hour ?? 0,   label: "HRS")
            separator
            unit(value: remaining.minute ?? 0, label: "MIN")
            separator
            unit(value: remaining.second ?? 0, label: "SEC")
        }
        .onAppear { tick() }
        .onReceive(timer) { _ in tick() }
    }

    private var separator: some View {
        Text(":")
            .font(.system(.title, design: .monospaced).bold())
            .foregroundStyle(theme.secondaryText)
    }

    private func unit(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", max(0, value)))
                .font(.system(.title, design: .monospaced).bold())
                .foregroundStyle(theme.accent)
            Text(label)
                .font(.caption2)
                .foregroundStyle(theme.secondaryText)
        }
    }

    private func tick() {
        remaining = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: Date(),
            to: target
        )
    }
}
