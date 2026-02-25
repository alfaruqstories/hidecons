# Hidecons

A simple macOS menu bar app to toggle desktop icons on/off.

## What it does

Shows an eye icon (👁) in your menu bar. Click it to hide or show desktop icons. Useful for clean workspaces or screenshots.

## How to use

### Option 1: Quick run (Terminal)

```bash
git clone https://github.com/alfaruqstories/hidecons.git
cd hidecons
swiftc Hidecons.swift -o Hidecons.app
./Hidecons.app/Contents/MacOS/Hidecons
```

### Option 2: Run the installer

```bash
git clone https://github.com/alfaruqstories/hidecons.git
cd hidecons
./install.sh
```

Move `Hidecons.app` to `/Applications` if you want it to persist.

## Note

When you toggle icons, Finder restarts briefly. If no other apps are open, macOS may switch away from your current desktop - just navigate back. Your icons will stay hidden.

## Features

- Click menu bar icon → Toggle desktop icons
- Click "Quit" → Restores icons before closing
- Runs in background (no dock icon)

## Requirements

- macOS 10.15+

## Troubleshooting

If you get a "file is corrupt" or "unidentified developer" warning when opening:
1. Right-click `Hidecons.app` → Open → click "Open"
2. Or run: `xattr -cr ~/Downloads/Hidecons.app`

This is a one-time macOS security check for unsigned apps.

## Fork & Use

This is free, open source. Fork it, modify it, use it however you want. No contributions needed—just fork and run.

## License

MIT
