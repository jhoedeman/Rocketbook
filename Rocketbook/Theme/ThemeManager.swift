//
//  ThemeManager.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    @Published var activeTheme: AppTheme

    private let defaults = UserDefaults.standard
    private let key = "selectedThemeID"

    init() {
        // Currently only one theme; future themes can be added here
        // and selected via stored key
        self.activeTheme = .deepSpace
    }

    func select(_ theme: AppTheme) {
        activeTheme = theme
        // persist selection key here when more themes are added
    }
}
