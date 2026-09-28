# CLAUDE.md

Rules Claude (or any similar coding agent) should follow when working in this repository.

## Core rules

1. **Think before coding.** If a request is ambiguous or could reasonably be read more than one way, ask a short clarifying question instead of guessing. A wrong assumption costs more to undo than a question costs to ask.
2. **Simplicity first.** No speculative abstractions, no extra configuration knobs, no code "for later." If a fix fits in 10 lines, it should not turn into 100. Don't leave dead code behind.
3. **Surgical changes.** Touch only what the task requires. Don't rewrite, reformat, or "clean up" unrelated code or comments — even code that looks wrong — unless asked.
4. **Goal-driven execution.** Before calling something done, verify it actually does what was asked (read it back, reason through the change, run it if possible). If you can't verify a change, say so explicitly rather than claiming success.

## Project overview

FutureEdu is a small iOS todo app used as a learning project for UIKit navigation, cross-screen data transfer, theming, and localization. It's a native Xcode project (`FutureEdu.xcodeproj`), not a Swift Package.

- **UI**: UIKit, built entirely in code (no Storyboard/XIB for actual screens). `Main.storyboard` exists in the project but is unused — `SceneDelegate` constructs the view hierarchy programmatically. `LaunchScreen.storyboard` *is* used and should stay laid out with Auto Layout constraints, not fixed frames.
- **Pattern**: MVVM with a light Clean Architecture split per feature:
  ```
  Features/<Feature>/
    Domain/Entities/        - plain value structs (e.g. TodoItem, TodoStats)
    Domain/Repositories/    - repository protocols
    Data/Repositories/      - protocol implementations
    Presentation/View/      - UIViewController / UIView subclasses
    Presentation/ViewModel/ - view models, no UIKit imports
  Core/
    Storage/                - LocalStorageService (UserDefaults + Codable)
    Theme/                  - AppTheme, ThemeManager
  ```
- **Persistence**: `LocalStorageService` wraps `UserDefaults` with `Codable` encode/decode. Feature repositories (e.g. `TodoRepository`) sit behind a protocol so view models stay testable and don't depend on UIKit or `UserDefaults` directly.
- **Theming**: `ThemeManager.shared` holds the current `AppTheme` (`.system` / `.light` / `.dark`), persists it, and applies it via `UIWindow.overrideUserInterfaceStyle`. It's attached once in `SceneDelegate` — don't create a second instance or apply the style anywhere else. Prefer semantic system colors (`.label`, `.systemGroupedBackground`, etc.) over hardcoded colors so both appearances stay correct automatically.
- **Localization**: `Localizable.xcstrings` is the single String Catalog holding English, Russian, and Uzbek. Every user-facing string must go through `NSLocalizedString(key:comment:)` — never hardcode UI text. When adding a string, add the key to `Localizable.xcstrings` with all three languages filled in, not just English.
- **Navigation patterns already established** (see `TodoViewController`, `TodoDetailViewController`, `StatsViewController`, `SettingsViewController` for reference):
  - Drill-down screens are **pushed** (`navigationController.pushViewController`), take their input via the initializer, and report changes back via an `@escaping` closure passed in at creation — not a delegate protocol, not `NotificationCenter`.
  - Standalone/self-contained screens are **presented modally** (`present(_:animated:)`), wrapped in their own `UINavigationController`.

## Build, run, and test

- No Swift/Xcode toolchain is available in this remote container, so changes can't be compiled or run here. Say so explicitly rather than claiming a build was verified — real verification requires opening the project in Xcode.
- The app target is `FutureEdu`; tests are `FutureEduTests` and `FutureEduUITests`.
- Unit tests use the modern **Swift Testing** framework (`import Testing`, `@Test`, `#expect(...)`), not XCTest — match that style for new tests, don't introduce `XCTestCase`.
- New `.swift` files under `FutureEdu/` are picked up automatically (the project uses Xcode 16 file-system-synchronized groups) — no manual `project.pbxproj` edits needed for adding source files. Manual edits to `project.pbxproj` are still required for project-level settings such as `knownRegions`.
- `.github/workflows/swift.yml` currently runs `swift build` / `swift test`, which assumes a Swift Package (`Package.swift`). This repo doesn't have one, so that workflow will not actually build this Xcode project as configured — worth flagging if asked to fix CI, rather than assuming it currently passes.
