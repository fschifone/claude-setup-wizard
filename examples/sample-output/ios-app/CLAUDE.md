# ios-app

Inherits rules from `../CLAUDE.md`. This file adds context specific to the SwiftUI client.

## Purpose
Internal iOS client for agents to review pending orders and approve/reject them on the go.

## Local structure
```
OrdergateApp/        ← SwiftUI views and view models
OrdergateCore/       ← Shared: models, API client, keychain wrapper
OrdergateTests/      ← XCTest
```

## Local commands
- Build: `xcodebuild -scheme Ordergate -configuration Debug`
- Test: `xcodebuild test -scheme Ordergate -destination "platform=iOS Simulator,name=iPhone 15"`
- Format: `swiftformat .`

## Local conventions
- MVVM — view models own all state, views are dumb.
- No business logic in views.
- API responses decoded with `Codable`, never manually parsed.
- UI state changes only on `@MainActor`.

## Gotchas specific to this area
- `APIClient` uses `URLSession` with a custom delegate for certificate pinning;
  don't swap it for a raw `URLSession.shared`.
- TestFlight builds require a separate signing identity configured in
  `Fastlane/Matchfile` — don't commit anything under `Fastlane/certs/`.
- The keychain wrapper crashes on simulator in DEBUG unless the
  `com.apple.security.application-groups` entitlement is present.
