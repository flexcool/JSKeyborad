# JSKeyborad — Agent Instructions

## Project overview

iOS keyboard extension app (Main App + Keyboard Extension only). No Widget target.
All compilation is via GitHub Actions — no local Xcode on dev machine.

- **App Group**: `group.com.jskeyboard.app`
- **Bundle IDs**: Main `com.jskeyborad.app`, Keyboard `com.jskeyborad.app.keyboard`
- **Deployment target**: iOS 16.0
- **CI**: unsigned builds; users self-sign with AltStore / Sideloadly

## Directory layout

```
JSKeyborad.xcodeproj/          # Xcode project (single .xcodeproj, no workspace)
.github/workflows/
  build.yml                    # push main/develop → build + test + lint + archive IPA
  release.yml                  # tag v* → archive + GH release with IPA
.swiftlint.yml                 # lint rules (see below)
JSKeyborad/
  Sources/                     # Main App SwiftUI code
    Views/
    Services/
    Models/
  KeyboardExtension/           # Keyboard extension
    Info.plist                 # ⚠️ EXPLICIT plist — do NOT set GENERATE_INFOPLIST_FILE=YES
    KeyboardViewController.swift
    KeyboardView.swift
```

## Build & test commands

```bash
# Build (CI command — also works locally)
xcodebuild clean build \
  -project JSKeyborad.xcodeproj \
  -scheme JSKeyborad \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2' \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# Archive IPA (release)
xcodebuild archive \
  -project JSKeyborad.xcodeproj \
  -scheme JSKeyborad \
  -archivePath ./build/JSKeyborad.xcarchive \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ENABLE_BITCODE=NO
```

```bash
# Lint
swiftlint lint --reporter github-actions-logging
```

## SwiftLint rules that trip up agents

These are enforced in CI (`|| true` on lint job but still reported):

| Rule | What to do |
|---|---|
| `sorted_imports` | `import SwiftUI` before `import UIKit` |
| `implicit_optional_initialization` | Write `@State var x: Foo?` not `= nil` |
| `force_unwrapping` | Use `guard let` not `!` |
| `for_where` | Use `for x in items where cond` not `for x in items { if cond … }` |
| `identifier_name` (min 2, max 60) | No single-letter vars like `i`, `r`, `g`, `b`, `a` |
| `todo` | Disabled — StoreKit TODOs are intentional |

## Keyboard extension gotchas

1. **`KeyboardExtension/Info.plist` is explicit.** Never set `GENERATE_INFOPLIST_FILE = YES` for the keyboard target — the system cannot create the extension placeholder from the generated plist. The plist must contain a valid `NSExtension` dictionary with `NSExtensionPointIdentifier` and `NSExtensionPrincipalClass`.

2. **Main app uses generated Info.plist.** The main app target uses `GENERATE_INFOPLIST_FILE = YES`. Do NOT add an explicit Info.plist or InfoPlist.swift to the build — Xcode will generate it from build settings.

3. **Sheet sheets need `.environmentObject`.** When presenting `TemplateEditView` or `FolderEditView` in a `.sheet`, always pass `.environmentObject(dataStore)` or it will crash on first access to `dataStore.folders`.

4. **Keyboard height constraint** is created once and updated, not recreated each `viewWillLayoutSubviews`.

5. **Keyboard layout is compact.** Templates are inserted on tap (not long-press). Keep views minimal — no nested scroll views without constraints.

6. **Remove iOS 17+ APIs.** Deployment target is iOS 16.0, so avoid APIs like `.scrollDismissesKeyboard(.interactively)`.

## Adding a new source file

Files go under `JSKeyborad/Sources/` in the appropriate subdirectory. The project uses SPM-style grouping — Xcode project files (`.pbxproj`) are hand-edited for new targets; new Swift files within an existing target should appear in the project automatically when opened in Xcode.

## Releasing

```bash
git tag v1.1.0 && git push origin v1.0.0   # triggers release.yml
```
The workflow creates a GH release with the IPA as an artifact.
