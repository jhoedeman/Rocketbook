//
//  AppTheme.swift
//  Rocketbook
//
//  Created by John A Hoedeman on 6/28/26.
//

import SwiftUI

struct AppTheme {
    var background: Color
    var surface: Color
    var accent: Color
    var success: Color
    var destructive: Color
    var primaryText: Color
    var secondaryText: Color
}

extension AppTheme {
    static let deepSpace = AppTheme(
        background:   Color("AppBackground"),
        surface:      Color("AppSurface"),
        accent:       Color("AppAccent"),
        success:      Color("AppSuccess"),
        destructive:  Color("AppDestructive"),
        primaryText:  Color("AppPrimaryText"),
        secondaryText: Color("AppSecondaryText")
    )
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .deepSpace
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
