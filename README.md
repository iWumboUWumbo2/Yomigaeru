# Yomigaeru

An iOS client for [Suwayomi](https://github.com/Suwayomi/Suwayomi-Server) targeting legacy iOS devices (iOS 5+).

## About

Yomigaeru (甦る - "to be revived") breathes new life into original iPads and other legacy iOS devices by providing a native manga reading experience through Suwayomi's server backend.

## Features

- Browse and read manga from Suwayomi sources
- Manage your manga library
- Support for multiple extensions/sources
- Optimized for iOS 5+ devices

## Requirements

- iOS 5.0 or later
- Xcode 5.0
- CocoaPods
- A running [Suwayomi server](https://github.com/Suwayomi/Suwayomi-Server)
    - Ensure that under the `Serve` tab under the `Conversions` tab in the `Suwayomi-Server Launcher`, `image/webp` is mapped to target `image/jpeg`. For low-spec devices, ensure compression is set as low as possible (ideally 0).

## Building

1. Clone the repository
2. Install dependencies:
   ```bash
   pod install
   ```
3. Open `Yomigaeru.xcworkspace` in Xcode
4. Build and run
