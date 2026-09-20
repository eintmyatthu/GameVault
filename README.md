# EHM GameShelf

EHM GameShelf is a native iOS and iPadOS app for discovering free-to-play games and building a personal game library. It uses the public FreeToGame API for game data and SwiftData for on-device persistence.

## Features

- **Discover games:** Browse popular titles, new releases, an alphabetical catalog, and common genres.
- **Search and filter:** Search by title, filter by genre and PC or browser platform, and sort by popularity, release date, name, or relevance.
- **View game details:** Explore descriptions, screenshots, release information, developer and publisher details, minimum system requirements, and official game links.
- **Manage a library:** Organize games into Wishlist, Playing, or Complete and change their status at any time.
- **Save favorites and ratings:** Mark a game as a favorite and assign or remove a personal rating from one to five stars.
- **Pick tonight's game:** Randomly choose a title from the Wishlist, view its details, or move it directly to Playing.
- **Track a player profile:** View library totals, favorite and play-status counts, top genres, and a locally stored display name.
- **Keep data between launches:** Library status, favorites, ratings, and profile preferences are stored on the device.

## App navigation

The app has four tabs:

| Tab | Purpose |
| --- | --- |
| Discover | Browse curated FreeToGame lists and genres. |
| Search | Find games by title and refine results with filters. |
| Library | Review saved games, update their status, and use the random picker. |
| Profile | See collection statistics, favorite genres, and profile settings. |

Selecting a game from Discover, Search, or Library opens its detail screen.

## Technology

- Swift and SwiftUI
- SwiftData
- Observation with `@Observable`
- URLSession with async/await
- Codable
- iOS and iPadOS 17+
- Xcode 16+

The project has no third-party package dependencies, backend, account system, or API-key requirement.

## Architecture

EHM GameShelf uses a lightweight MVVM structure:

```text
SwiftUI Views
  ├── @Observable ViewModels ──> FreeToGameService ──> FreeToGame API
  └── LibraryViewModel ────────> SwiftData ModelContext ──> SavedGame
```

- **Models** map FreeToGame responses and define the locally persisted `SavedGame` record.
- **Services** build API requests, validate HTTP responses, and decode JSON.
- **ViewModels** own asynchronous loading, search, detail, and persistence operations.
- **Views** render the four-tab interface and react to SwiftData queries.
- **Components** provide shared artwork, theme, loading, empty, and error states.

Each game is stored once by its FreeToGame ID. Its library status, favorite flag, and personal rating are updated on the same SwiftData record.

## Project structure

```text
GameVault/
├── GameVaultApp.swift
├── ContentView.swift
├── Models/
│   ├── Game.swift
│   ├── GameDetail.swift
│   └── SavedGame.swift
├── Services/
│   ├── APIConfig.swift
│   └── FreeToGameService.swift
├── ViewModels/
│   ├── DiscoverViewModel.swift
│   ├── GameDetailViewModel.swift
│   ├── LibraryViewModel.swift
│   └── SearchViewModel.swift
├── Views/
│   ├── Detail/
│   ├── Discover/
│   ├── Library/
│   ├── Profile/
│   └── Search/
└── Components/
    ├── GameArtwork.swift
    ├── StateViews.swift
    └── Theme.swift
```

## Requirements

- A Mac with Xcode 16 or newer
- An iPhone or iPad running iOS/iPadOS 17 or newer, or a compatible simulator
- An internet connection for discovering, searching, and loading full game details

Saved library metadata and profile statistics remain available without a network connection.

## Getting started

1. Open `GameVault.xcodeproj` in Xcode.
2. Select the **GameVault** scheme.
3. Choose an iOS simulator or a connected device.
4. Press **⌘R** to build and run the app.

No additional setup is required. When running on a physical device, select your own development team under **Signing & Capabilities** if Xcode requests it.

## Command-line build

From the repository root, run:

```sh
xcodebuild \
  -project GameVault.xcodeproj \
  -scheme GameVault \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/EHMGameShelfBuild \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Data and privacy

- Game information and artwork are requested from FreeToGame.
- Library records, favorites, ratings, and the profile name are stored locally.
- The app does not require an account and does not provide cloud synchronization.
- Removing a game from the Library preserves an independent favorite or rating; the record is deleted only when it is no longer needed.

## Data source

Game information and artwork are provided by [FreeToGame](https://www.freetogame.com). See the [FreeToGame API documentation](https://www.freetogame.com/api-doc) for details.

## Team

- Eaint Myat Thu — 6726125
- Htin Aung Lynn — 6726116
- Mi Hsu Myat Win Myint — 6726115
