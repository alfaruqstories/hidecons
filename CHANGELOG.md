# Changelog

All notable changes to Hidecons are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.5.0] — 2026-03-01

### Changed
- Menu bar icon changed from eye to grid (`square.grid.2x2`)
  - Outline grid = icons visible, filled grid = icons hidden
- Removed manual Login Items instructions from README and install.sh — Launch at Login is now in-app

---

## [1.4.0] — 2026-03-01

### Added
- **Launch at Login** toggle in the menu bar — no System Settings needed
  - macOS 13+: uses `SMAppService`
  - macOS 10.15–12: writes a LaunchAgent plist to `~/Library/LaunchAgents/`
- Dynamic menu label: "Hide Desktop Icons" or "Show Desktop Icons" based on current state
- `import ServiceManagement` and `-framework ServiceManagement` compile flag

### Fixed
- Toggle menu item was a local variable and got discarded after setup — now stored as an instance variable
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
