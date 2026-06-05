# SnackbarKit

A lightweight, dependency-free snackbar library for SwiftUI.

[![Swift 6](https://img.shields.io/badge/Swift-6-F05138.svg)](https://swift.org)
[![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue.svg)](#requirements)
[![macOS 12+](https://img.shields.io/badge/macOS-12%2B-blue.svg)](#requirements)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](#installation)

Show transient, queued notifications anchored to the bottom of the screen —
with auto-dismiss, swipe-to-dismiss, smooth replacement animations,
and VoiceOver support out of the box.

---

## Features

- **Four styles** — success, error, info, warning, each with its own icon and colour
- **Queued** — call `show()` as many times as you like; items appear one after another
- **Auto-dismiss** with a configurable duration per item
- **Swipe-to-dismiss** — drag the pill down to close it early
- **Sticky mode** — pass `duration: 0` to keep a snackbar up until dismissed manually
- **Accessible** — announces on appear; exposes a VoiceOver dismiss action
- **Swift 6 / strict concurrency** — fully `@MainActor`-isolated, zero warnings
- **Zero dependencies**

---

## Requirements

| | Minimum |
|---|---|
| iOS | 15.0 |
| macOS | 12.0 |
| Swift | 6.0 |
| Xcode | 16.0 |

---

## Installation

In Xcode: **File → Add Package Dependencies…** and enter:

```
https://github.com/IKiprotich/SnackbarKit.git
```

Or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/IKiprotich/SnackbarKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SnackbarKit"]
    )
]
```

---

## Quick start

1. Create a `SnackbarManager` at the root of your view hierarchy.
2. Attach the host overlay once with `.snackbar(manager:)`.
3. Call `show()` from anywhere you hold the manager.

```swift
import SwiftUI
import SnackbarKit

struct ContentView: View {
    @StateObject private var snackbar = SnackbarManager()

    var body: some View {
        VStack(spacing: 16) {
            Button("Save")   { snackbar.show("Profile saved",  style: .success) }
            Button("Delete") { snackbar.show("Upload failed",  style: .error)   }
            Button("Sync")   { snackbar.show("Syncing…",       style: .info)    }
            Button("Warn")   { snackbar.show("Low battery",    style: .warning) }
        }
        .snackbar(manager: snackbar)
    }
}
```

---

## Usage

### Styles

```swift
snackbar.show("All good",        style: .success)
snackbar.show("Something broke", style: .error)
snackbar.show("Heads up",        style: .info)    // default
snackbar.show("Low battery",     style: .warning)
```

### Custom duration

```swift
snackbar.show("Quick note",     duration: 1.5)  // disappears after 1.5 s
snackbar.show("Take your time", duration: 5.0)  // stays for 5 s
```

### Sticky snackbars

Pass `duration: 0` to keep the snackbar on screen until the user swipes it
away or you dismiss it programmatically:

```swift
snackbar.show("No internet connection", style: .error, duration: 0)
```

### Programmatic dismiss

```swift
snackbar.dismiss()
```

Dismisses the current snackbar and immediately advances to the next
queued item, if any.

### Pre-built items

Supply your own `SnackbarItem` when you need control over the item's
identity — for example, to deduplicate:

```swift
let item = SnackbarItem(id: myStableID, message: "Synced", style: .success, duration: 2)
snackbar.show(item)
```

---

## Accessibility

- **Announced on appear** — VoiceOver reads the message aloud the moment
  the snackbar slides in, using the back-deployed accessibility notification
  (iOS 15+).
- **Dismiss action** — the swipe gesture is mirrored by a VoiceOver rotor
  action labelled "Dismiss", so screen-reader users are never locked out.
- **Decorative icon hidden** — the style icon is marked hidden from
  VoiceOver; only the message text is read.

---

## Known limitations

- **Sheets and full-screen covers** — the overlay renders inside the view
  hierarchy it's attached to, so it appears behind a presented `sheet` or
  `fullScreenCover`. To show snackbars inside a presented view, attach
  `.snackbar(manager:)` there instead.
- **Icon size** — the style icon does not yet scale with Dynamic Type.

---

<details>
<summary>How it works</summary>

`SnackbarManager` is an `@MainActor` `ObservableObject` that publishes a
single `current: SnackbarItem?`. Calling `show()` either presents the item
immediately (if nothing is visible) or appends it to an internal queue.
Each presented item arms a cancellable `Task` that calls `dismiss()` after
the configured duration. `dismiss()` cancels that task and either clears
`current` or synchronously advances to the next queued item — so the
auto-dismiss timer and a manual dismiss can never race and drop an item.

The view layer is a `ViewModifier` that places a bottom-anchored pill in a
`ZStack`. Each item is keyed by its `UUID` via `.id()`, so SwiftUI plays a
move-and-fade transition on both insertion and replacement.

</details>

---

## Use it freely

No license restrictions. Use it in personal or commercial projects, modify it, build on it. No attribution required — just ship something great.
