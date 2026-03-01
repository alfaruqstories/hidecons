# Hidecons

A lightweight macOS menu bar app to hide and show desktop icons instantly.

---

## What it does

Sits in your menu bar as a small grid icon. One click hides all desktop icons; another click brings them back. Useful for clean screenshots, presentations, or a distraction-free workspace.

- **Outline grid** — icons are visible
- **Filled grid** — icons are hidden

---

## Install

```bash
git clone https://github.com/alfaruqstories/hidecons.git
cd hidecons
./install.sh
```

The script compiles the Swift source, builds an app bundle, installs it to `~/Applications/Hidecons.app`, and launches it immediately.

---

## Usage

After launching, a grid icon appears in your menu bar.

| Action | Result |
|---|---|
| **Left click** the icon | Instantly toggles desktop icons |
| **⌥⌘H** (anywhere) | Same toggle, no mouse needed |
| **Right click** the icon | Opens settings menu |
| Undo | Reverts the last toggle (shown in menu after any toggle) |
| Launch at Login | Toggles auto-start on login (checkmark = enabled) |
| Notify on Toggle | Enables a macOS notification on each hide/show |
| Report a Bug | Opens GitHub Issues |
| Quit | Exits — icons stay in their current state |

**State is remembered across reboots.** If your icons were hidden when you shut down, they stay hidden when you start up. Hidecons reads the current Finder preference on launch and picks up from there.

**Launch at Login** is built into the app — no System Settings or Login Items configuration needed.

---

## How it works

Hidecons writes a single macOS preference and restarts Finder:

```bash
defaults write com.apple.finder CreateDesktop -bool false
killall -HUP Finder
```

This is the standard technique used by all desktop-hiding utilities on macOS. Finder restarts in under a second and re-reads its preferences. The preference persists in Finder's plist — no database or separate config file.

---

## Requirements

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools (`xcode-select --install`)

---

## Troubleshooting

**"App is damaged" or "unidentified developer" warning**

The app is not notarised by Apple. To open it anyway:

```bash
xattr -cr ~/Applications/Hidecons.app
```

Or right-click the app → Open → click "Open" in the dialog.

**Desktop icons don't come back after quitting**

Run this in Terminal to restore manually:

```bash
defaults write com.apple.finder CreateDesktop -bool true && killall -HUP Finder
```

---

## License

MIT — fork it, modify it, ship it.
