# Rocketbook — Xcode Setup

## 1. Create the Xcode project

- New Project → iOS → App
- Product Name: `Rocketbook`
- Interface: SwiftUI, Language: Swift
- **Delete** the auto-generated `ContentView.swift` — use the one from this folder

## 2. Add source files

Drag the entire `Rocketbook/` folder into the Xcode project navigator. Make sure
"Copy items if needed" is checked.

## 3. Add Asset Catalog colors

Open `Assets.xcassets` and create these Color Sets. For each one, set
**Appearances → Any, Dark** and enter the hex values:

| Name              | Any (Light)  | Dark         |
|-------------------|-------------|--------------|
| AppBackground     | #F2F2F7     | #0A0A0F      |
| AppSurface        | #FFFFFF     | #12141F      |
| AppAccent         | #3D8EFF     | #3D8EFF      |
| AppSuccess        | #30D158     | #30D158      |
| AppDestructive    | #FF453A     | #FF453A      |
| AppPrimaryText    | #000000     | #FFFFFF      |
| AppSecondaryText  | #8E8E93     | #8E8E93      |

## 4. Enable Push Notifications capability (optional)

For local notifications to work no capability is needed. If you later want
remote notifications: Signing & Capabilities → + Capability → Push Notifications.

## 5. Build & run

Select an iOS 17+ simulator and run. The app uses async/await throughout so
iOS 15+ is the minimum, but `ContentUnavailableView` requires iOS 17.
To support iOS 15/16, replace `ContentUnavailableView` with a custom empty state view.
