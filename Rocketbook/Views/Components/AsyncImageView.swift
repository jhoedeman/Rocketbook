//
//  AsyncImageView.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct AsyncImageView: View {
    let urlString: String?
    var contentMode: ContentMode = .fit
    @Environment(\.theme) private var theme

    var body: some View {
        if let str = urlString, let url = URL(string: str) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    placeholder
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(theme.surface)
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(theme.secondaryText)
            )
    }
}
