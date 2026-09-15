# EHMGameShelf

EHMGameShelf is a native iOS application for discovering free-to-play games, organizing a personal backlog, rating games, and recording play experiences.

## Team

- Eaint Myat Thu — 6726125
- Htin Aung Lynn — 6726116
- Mi Hsu Myat Win Myit — 6726115

## Features

- **Discover:** Browse popular, newly released, and alphabetical free-to-play games.
- **Search and filters:** Search by title, filter by genre and PC/browser platform, and sort by popularity, release date, name, or relevance.
- **Game details:** Read descriptions and metadata, swipe through screenshots, view minimum requirements, and open the official game page.
- **My Backlog:** Save games as Want to Play, Playing, or Stopped; change status or remove a game later.
- **Personal ratings:** Set, update, or remove a one-to-five-star rating.
- **Play Journal:** Create, edit, and delete dated entries associated with games in the backlog.
- **Pick Tonight's Game:** Randomly select a Want to Play title, view its details, choose again, or move it to Playing.
- **Local persistence:** Backlog statuses, ratings, favorites, and journal entries remain available after relaunch.

## Application structure

The four tabs are Discover, Search, Backlog, and Journal. Selecting a game opens its detail screen.

```text
GameVault/
  Models/          FreeToGame DTOs and SwiftData records
  Services/        FreeToGame URLSession client
  ViewModels/      Discovery, search, details, and persistence logic
  Views/           Discover, Search, Detail, Library/Backlog, and Journal UI
  Components/      Shared visual and state components
```

## Technology

- Swift and SwiftUI
- SwiftData
- URLSession with async/await
- Codable
- iOS 17+

The app uses the public [FreeToGame API](https://www.freetogame.com/api-doc). No API key or account is required. Game information and artwork are attributed to [FreeToGame](https://www.freetogame.com).

## Run

1. Open `GameVault.xcodeproj` in Xcode 16 or newer.
2. Select the GameVault scheme and an iOS simulator or device.
3. Press **Command-R**.

No packages, API keys, backend, or database setup are required.

## Verification

Build from Terminal:

```sh
xcodebuild -project GameVault.xcodeproj -scheme GameVault \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/EHMGameShelfBuild CODE_SIGNING_ALLOWED=NO build
```
