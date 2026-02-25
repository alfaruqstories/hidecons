# Hidecons

A simple macOS menu bar app to toggle desktop icons on/off.

## What it does

Shows an eye icon (👁) in your menu bar. Click it to hide or show desktop icons. Useful for clean workspaces or screenshots.

## How to use

### Option 1: Download directly

Download `Hidecons.zip` from this repo, unzip it, and double-click `Hidecons.app`.

### Option 2: Run the installer

```bash
git clone https://github.com/alfaruqstories/hidecons.git
cd hidecons
./install.sh
```

### Option 3: Build manually

```bash
git clone https://github.com/alfaruqstories/hidecons.git
cd hidecons
swiftc Hidecons.swift -o Hidecons.app
open Hidecons.app
```

Move `Hidecons.app` to `/Applications` if you want it to persist.

## Features

- Click menu bar icon → Toggle desktop icons
- Click "Quit" → Restores icons before closing
- Runs in background (no dock icon)

## Requirements

- macOS 10.15+
- Finder will restart when toggling (brief flash)

## Fork & Use

This is free, open source. Fork it, modify it, use it however you want. No contributions needed—just fork and run.

## License

MIT
