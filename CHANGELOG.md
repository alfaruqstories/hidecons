# Changelog

All notable changes to Hidecons are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.7.0] — 2026-03-02

### Added
- **Global keyboard shortcut ⌥⌘H** — toggle from anywhere without touching the mouse
      → `NSEvent.addGlobalMonitorForEvents`; monitor cleaned up on quit
      → Shortcut displayed next to toggle item in right-click menu for discoverability
- **Restore indicator** — menu bar icon pulses between `arrow.clockwise` and `square.grid.2x2` while Finder reloads the desktop after a show operation
      → Restoring takes longer than hiding (Finder must re-enumerate and render all files); indicator makes the in-progress state visible
      → Tooltip reads "Desktop icons: restoring…" during pulse; settles after 2 seconds
      → Hide remains instant with no indicator
- **Undo last toggle** — right-click menu shows "Undo — Restore Icons" or "Undo — Hide Icons" after any toggle
      → Single-level undo buffer; clears after use; disabled when nothing to undo
- **Notify on Toggle** — optional macOS notification on each hide/show
      → Off by default; requests permission on first enable; checkmark in menu
- **Haptic feedback** — subtle Force Touch tap on every toggle (MacBooks with Force Touch trackpad)
      → `NSHapticFeedbackManager`
- **Menu bar tooltip** — hover the icon to see "Desktop icons: hidden" or "Desktop icons: visible"
- **Report a Bug** — right-click menu item opens GitHub Issues in the browser
- **Refresh Launch at Login state** — re-reads live from SMAppService on every right-click open; stays in sync if user removes the app from System Settings manually

### Changed
- Menu bar icon uses `isTemplate = true` — adapts automatically to dark/light/tinted menu bars
- Menu structure: `Hide/Show ⌥⌘H` → `Undo` → `─` → `Launch at Login` → `Notify on Toggle` → `─` → `Report a Bug` → `Quit`

---

## [1.6.0] — 2026-03-01

### Added
- **Instant toggle on left click** — click the grid icon to toggle immediately, no menu required
- **Right-click opens settings menu** — Launch at Login and Quit accessible via right-click
- **Custom app icon** — blue rounded-rect with white 2×2 grid; shows correctly in System Settings → Login Items
- `generate_icon.swift` — builds `AppIcon.icns` at all 10 required sizes during install
- `.gitignore` — ignores build artefacts, `.DS_Store`, and local-only files

### Changed
- **State remembrance** — app no longer restores icons on quit; Finder prefs persist naturally across reboots
- `install.sh` compiles and runs `generate_icon.swift`, packs `AppIcon.icns`, references it in `Info.plist`
- `CFBundleVersion` bumped to `1.6`

### Removed
- Icon restore on quit (replaced by state remembrance)

---

## [1.5.0] — 2026-03-01

### Changed
- Menu bar icon changed from eye (`eye`) to grid (`square.grid.2x2`)
  - Outline grid = icons visible, filled grid = icons hidden
- Removed manual Login Items step from README and install.sh — Launch at Login is now in-app

---

## [1.4.0] — 2026-03-01

### Added
- **Launch at Login** toggle built into the menu — no System Settings needed
  - macOS 13+: uses `SMAppService`
  - macOS 10.15–12: writes a LaunchAgent plist to `~/Library/LaunchAgents/`
- Dynamic menu label: "Hide Desktop Icons" / "Show Desktop Icons" based on current state
- `import ServiceManagement` and `-framework ServiceManagement` compile flag

### Fixed
- Toggle menu item was a local variable and got discarded after setup — now stored as instance variable
- Deprecated `task.launch()` / `task.launchPath` replaced with `try? task.run()` / `task.executableURL`
- State and UI no longer update if the `defaults write` command fails
- Quit path used bare `killall Finder` (SIGTERM); changed to `killall -HUP Finder` to match toggle path

---

## [1.3.0] — 2024

### Added
- Code-signed app bundle to reduce Gatekeeper friction
- Troubleshooting section in README for "unidentified developer" warnings

---

## [1.2.0] — 2024

### Changed
- Renamed from "Desktop Toggle" to **Hidecons**
- Unified branding across repo, app bundle, and all documentation

---

## [1.1.0] — 2024

### Added
- Pre-built app bundle for direct download
- `install.sh` — one-command build and install script
- README with usage instructions and direct download link

---

## [1.0.0] — 2024

### Added
- Initial release
- Menu bar app to toggle macOS desktop icons on/off
- Uses `defaults write com.apple.finder CreateDesktop` + `killall -HUP Finder`
- Eye icon in menu bar (outline = visible, slash = hidden)
- Restores desktop icons automatically on quit
- No dock icon — runs silently in the background
- macOS 10.15+ support
