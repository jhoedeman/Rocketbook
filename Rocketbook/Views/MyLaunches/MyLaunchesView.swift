//
//  MyLaunchesView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct MyLaunchesView: View {
    @StateObject private var vm = MyLaunchesViewModel()
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            Group {
                if vm.items.isEmpty && !vm.isLoading {
                    ContentUnavailableView(
                        "No rockets tracked",
                        systemImage: "bell.slash",
                        description: Text("Tap the bell on any rocket to get launch notifications")
                    )
                } else {
                    List(vm.items) { item in
                        NavigationLink(destination: RocketDetailView(rocket: item.rocket)) {
                            MyLaunchRow(item: item)
                        }
                        .listRowBackground(theme.surface)
                    }
                    .scrollContentBackground(.hidden)
                    .background(theme.background)
                }
            }
            .navigationTitle("My Launches")
        }
        .task { await vm.load() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await vm.load() }
        }
    }
}

private struct MyLaunchRow: View {
    let item: MyLaunchesViewModel.Item
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.rocket.name)
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundStyle(theme.accent)
            }

            if let launch = item.nextLaunch, let net = launch.net {
                Text(launch.name)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
                CountdownView(target: net)
            } else {
                Text("No upcoming launch scheduled")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .padding(.vertical, 6)
    }
}
