# Rocketbook

A native SwiftUI iOS app for browsing rocket launches, tracking your favorite
rockets, and following specific launches with local reminders before they
lift off.

## Features

- Browse rockets by manufacturer and family, with images and details
- Live countdowns and current mission status (upcoming / success / failure)
- Favorite rockets for quick access
- "My Launches" — follow specific launches and get notified before they go
- Dark-mode-first design with a custom theming system

## Data source

Launch and rocket data comes from
[The Space Devs' Launch Library 2 API](https://thespacedevs.com/llapi).

## Stack

Swift + SwiftUI (iOS 17+) · async/await networking · UserNotifications for
launch reminders.

## Project setup

See [SETUP.md](SETUP.md) for step-by-step Xcode project setup, including
the asset catalog colors and capabilities the app needs.
