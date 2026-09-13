# GameVault

A native iOS game discovery and personal library app for a university final project. Discover games from RAWG, search by title or genre, explore game details, and keep favorites and Wishlist, Playing, and Completed collections on your device.

## Features

- **Discover:** Popular Games, Top Rated, New Releases from the past three months, genre browsing, artwork carousels, and pull-to-refresh.
- **Search:** 450 ms debounce, cancellable requests, genre filters, and paginated results. Stale responses cannot overwrite a newer search.
- **Game Detail:** Hero artwork, ratings, Metacritic, genres, platforms, release date, developers, publishers, age rating, description, and official website when available.
- **Library:** Local collections, status filters, status changes, and confirmed removal.
- **Favorites:** Independent of collection status, accessible in My Vault.
- **My Vault:** Live collection counts, favorite counts, and genre percentages calculated from saved records.
- **UI:** Four tabs, per-tab navigation stacks, reusable rounded cards, adaptive colors, Dark Mode, Dynamic Type, loading/error/empty states, accessible actions, favorite animation, and save haptics.

## Technologies

Swift, SwiftUI, iOS 17+, SwiftData, Observation, URLSession, async/await, Codable, NavigationStack, TabView, AsyncImage. No backend or third-party dependencies.

The project uses Xcode's synchronized folder groups; use Xcode 16 or newer. Verified with Xcode 26.5 and an iOS 26.5 simulator. The deployment target is iOS 17.0; execution on iOS 17 has not been separately tested.

## Installation and API key

1. Open `GameVault.xcodeproj` in Xcode.
2. Obtain your own key from [RAWG API](https://rawg.io/apidocs).
3. Recommended for development: select **Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables**. Add `RAWG_API_KEY` with your key and enable it.
4. Alternatively, replace `PUT_YOUR_RAWG_API_KEY_HERE` in `GameVault/Services/APIConfig.swift`. That is the only source-code key location. Do not commit a real key. Environment configuration takes precedence.
5. Choose the **GameVault** scheme and an iPhone or iPad simulator, then press **⌘R**.
6. For a physical iPhone, select your signing team under Signing & Capabilities if the existing team is unavailable. The existing project name and `emery.GameVault` bundle identifier are preserved.

No packages, server, database setup, or manual target membership changes are required. Scheme environment variables are injected by Xcode when running; a standalone installation launched outside Xcode needs the locally configured source key. Fully stop and rerun after changing the key.

Without a key, API screens display setup guidance. Library and My Vault still work locally. There are no hard-coded game results in the app.

## Architecture

```text
View → @Observable ViewModel → RAWGService → URLSession → RAWG REST API
View → LibraryViewModel → ModelContext → SavedGame → persistent store
@Query → updates Library, Game Detail favorite state, and My Vault
```

- **Models:** Codable structs map API JSON. Optional API fields support null/missing values. `CodingKeys` maps snake_case.
- **Service:** One generic request method builds encoded query items, validates HTTP responses, decodes data, and maps errors. No API key logging.
- **ViewModels:** Main-actor state for asynchronous loading, search cancellation, details, and persistence mutations.
- **Views:** Layout and interaction. SwiftData `@Query` provides reactive saved records directly, a standard SwiftUI pattern.
- **Components:** Shared theme, artwork placeholders, cards, filter chips, and state views.

Discover loads its sections concurrently and publishes a complete result together. If one request fails, Retry reruns the group. Search supports Load More without trusting an arbitrary next-page URL. Only IDs and genres from RAWG are used for genre navigation.

## SwiftData persistence

`SavedGame` is separate from API structs. Each record stores a unique RAWG ID, name, artwork URL, rating, genres, platform names, release date, Metacritic, optional status string, favorite flag, and date added.

Saving fetches the RAWG ID first and updates the existing record. `@Attribute(.unique)` also enforces identity. Every user change explicitly calls `context.save()`; failures roll back and display an alert.

A game can have a library status, be a favorite, or both. Removing from Library clears only its status. Removing its last remaining membership deletes the record. Local metadata remains readable without a network; full descriptions require RAWG. Artwork uses AsyncImage and is not guaranteed to be available offline.

Games Collected counts records with collection status, excluding favorite-only records. Genre percentages count saved records containing each genre divided by all saved records. Since games have multiple genres, percentages need not sum to 100%.

The persistent ModelContainer is created once at startup. Store-open errors show Retry without replacing or deleting the database. Data stays on this device; there is no account or cloud sync.

## Project structure

```text
GameVault/
  GameVaultApp.swift             App and persistent container
  ContentView.swift              Four tabs and navigation destinations
  Models/
    Game.swift                  Game, response, genre, platform DTOs
    GameDetail.swift            Detail DTO
    SavedGame.swift             SwiftData model and LibraryStatus
  Services/
    APIConfig.swift
    RAWGService.swift
  ViewModels/
    DiscoverViewModel.swift
    SearchViewModel.swift
    GameDetailViewModel.swift
    LibraryViewModel.swift
  Views/
    Discover/                   Discover, cards, carousels
    Search/                     Search and result rows
    Detail/                     Game Detail and save actions
    Library/                    Collection filters and management
    Vault/                      Statistics, favorites, attribution
  Components/                   Theme, artwork, state views
Tests/
  GameVaultChecks.swift          Standalone production-code checks
  run-checks.sh
 docs/screenshots/
```

## Validation

Build from Terminal:

```sh
xcodebuild -scheme GameVault -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/GameVaultBuild CODE_SIGNING_ALLOWED=NO build
```

Run the standalone checks on a Mac with Xcode:

```sh
Tests/run-checks.sh
```

These compile the production models, networking service, and persistence view model. A temporary SwiftData store is written in one process and reopened in another. URLProtocol supplies test-only networking responses; no key or external network is needed. This is a standalone check harness, not an Xcode XCTest target.

**Verified:** iOS simulator build and startup; visual inspection of the no-key Discover screen; null/missing-field decoding; mocked URLSession success; 401/403/429/500 responses; malformed JSON; unique saves; status changes; independent favorites; persistence across processes; removal preserving favorites; deletion of an unused record.

**Remaining manual checks:** Live RAWG data needs your key. Full UI interaction was not automated because Computer Use permissions were unavailable. Persistence checks ran against the production SwiftData model on macOS; use the iOS relaunch demonstration below as well.

### Presentation / acceptance checklist

- [ ] Add key, run, and confirm three Discover carousels and genre browsing load real artwork and games.
- [ ] Search **Elden Ring**; confirm debounce, loading, matching results, filters, and Load More.
- [ ] Open details from Discover and Search; check metadata and description.
- [ ] Add Elden Ring to Wishlist and favorite it. Confirm the heart and save feedback.
- [ ] Open Library; confirm Wishlist and the same game. Change to Playing, then Completed; confirm there is only one record.
- [ ] Return it to Wishlist; terminate the app completely, reopen, and verify Wishlist and favorite state remain.
- [ ] Confirm My Vault counts and genres change with saved records.
- [ ] Remove from Library, cancel once, then confirm. Confirm the favorite remains in My Vault.
- [ ] Unfavorite it; confirm it disappears from Favorites.
- [ ] Disable internet: Library metadata and counts remain available; API screens show Retry.
- [ ] Try a nonsense search, a wrong key, missing artwork, Dark Mode, larger text, iPad layout, and VoiceOver.

## Screenshots

Current simulator capture (setup state; no API key supplied):

<img src="docs/screenshots/discover-setup.png" width="280" alt="GameVault Discover setup screen with four tabs" />

Add presentation screenshots after configuring RAWG:

| Screen | Suggested filename |
| --- | --- |
| Discover with real results | `docs/screenshots/discover.png` |
| Search results | `docs/screenshots/search.png` |
| Game Detail | `docs/screenshots/detail.png` |
| Saved Library | `docs/screenshots/library.png` |
| My Vault statistics | `docs/screenshots/vault.png` |

## 10-minute presentation outline

1. **1 min:** Purpose, four tabs, and Game Detail navigation.
2. **2 min:** Discover and Search; explain View → ViewModel → service.
3. **2 min:** Show Codable mappings, async URLSession request, HTTP validation, and loading/error UI.
4. **2 min:** Save/favorite a game; explain unique ID and independent state. Terminate and reopen to demonstrate persistence.
5. **2 min:** Library filters, My Vault calculations, reusable UI, and accessibility.
6. **1 min:** Testing, limitations, and future ideas such as screenshot galleries and offline image caching.

## Data source and attribution

Game information and artwork are provided by [RAWG](https://rawg.io). API documentation: [RAWG API reference](https://api.rawg.io/docs/). Attribution links are included in Discover, Game Detail, and My Vault. Follow RAWG's current usage terms for your key and distribution. Game artwork and names belong to their respective owners.

## Team

- [Team member name] — [Student ID] — [Contribution]
- [Team member name] — [Student ID] — [Contribution]
