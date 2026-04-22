# Mac Battery Alert

A lightweight macOS menu bar app that shows battery reminders without using macOS notification banners.

## What it does

- Shows a custom banner at the top of the screen when battery is low.
- Shows a custom banner at the top of the screen when charging reaches your target percentage.
- Lets you configure the thresholds, with defaults of `40%` for low battery and `80%` for charged.
- Runs as a menu bar accessory instead of a dock app.
- Opens the settings window on first launch so the app is easy to find.
- Supports launch at login when you run the packaged `.app` bundle.

## Run it

```bash
swift run
```

Look for the battery percentage in your menu bar. If this is the first launch, the settings window opens automatically.

## Build A Double-Clickable App

```bash
./scripts/build-app.sh
open dist/MacBatteryAlert.app
```

## Open in Xcode

```bash
open Package.swift
```
