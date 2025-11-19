# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Garmin Connect IQ watchface application called "Cyberpunk" written in Monkey C. It features a cyberpunk-themed design with time display, date, health metrics (heart rate, steps), and battery status.

## Build and Development Commands

This project uses the Garmin Connect IQ SDK. Common commands should be run from Visual Studio Code with the Monkey C extension:

- **Build**: Use "Monkey C: Build for Device" from the VS Code command palette
- **Run on Simulator**: Use "Monkey C: Run" from the VS Code command palette
- **Export .PRG file**: Use "Monkey C: Export Project" from the VS Code command palette

### Direct Build Command

To compile, build, and launch the simulator directly using monkeybrains.jar:

```bash
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar c:\Users\jean-baptiste.bayle\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.2.3-2025-08-11-cac5b3b21\bin\monkeybrains.jar -o bin\Cyberpunk.prg -f c:\Users\jean-baptiste.bayle\Desktop\programmation\Garmin\Cyberpunk\monkey.jungle -y c:\Users\jean-baptiste.bayle\Documents\developer_key -d fr970_sim -w
```

Parameters:
- `-o bin\Cyberpunk.prg` - Output .prg file location
- `-f monkey.jungle` - Project manifest file
- `-y developer_key` - Path to developer key for signing
- `-d fr970_sim` - Target device (Forerunner 970 simulator)
- `-w` - Launch simulator after build

The `manifest.xml` is auto-generated - use VS Code Monkey C commands to edit application settings, products, permissions, languages, and barrels rather than manually editing this file.

## Architecture

### Entry Point
- `source/CyberpunkApp.mc` - Main application class extending `Application.AppBase`
  - `getInitialView()` returns `CyberpunkView` as the watchface view
  - `onSettingsChanged()` triggers UI updates when settings change

### View Layer
- `source/CyberpunkView.mc` - Main watchface view extending `WatchUi.WatchFace`
  - Implements a custom-drawn cyberpunk aesthetic with circular design elements
  - Uses selective redrawing for performance: full redraw only when `needsFullRedraw` is true, otherwise only clears and redraws the time area
  - Caches screen dimensions and scaling factors for efficient rendering

### View Architecture Details

**Rendering Strategy**:
- `onUpdate()` uses conditional rendering: full redraw vs. time-only update
- `drawBackground()` renders static elements (decorative circles, hour markers, progress arc, corner points)
- Dynamic content (time, date, stats) is redrawn every update
- Background cleared to `bgColor` (0x0a0e27) on every frame

**Visual Elements**:
- Dual concentric circles with cyan accent color (0x00D4FF)
- Hour markers at 12, 3, 6, 9 positions
- Battery-based progress arc (270° sweep from top)
- Decorative points in corners (cyan and purple)

**Data Display**:
- Time: Large central display (FONT_NUMBER_HOT) with seconds below (FONT_TINY)
- Date: Format "DAY DD MON" (e.g., "WED 19 NOV") in secondary color
- Stats row: Heart rate (ECG icon), Steps (in K format), Battery (icon + percentage)

**Heart Rate Handling**:
- First attempts `Activity.getActivityInfo().currentHeartRate`
- Falls back to `ActivityMonitor.getHeartRateHistory(1, true)` if unavailable
- Returns null if no data available

**Scaling System**:
- All dimensions use `scale` factor based on `screenWidth / 240.0`
- Ensures consistent layout across different Garmin device screen sizes

### Background Drawable
- `source/CyberpunkBackground.mc` - Simple background drawable that reads BackgroundColor property (currently unused in main view which uses custom rendering)

### Resources
- `resources/strings/strings.xml` - Localized strings including app name and settings
- `resources/settings/properties.xml` - User-configurable properties (BackgroundColor, ForegroundColor, UseMilitaryFormat)
  - Note: Current implementation doesn't use these properties in CyberpunkView; they're defined but not actively applied

### Device Support
Supports 110+ Garmin devices including:
- Fenix series (5, 6, 7, 8, Chronos, E)
- Forerunner series (55, 165, 245, 255, 265, 570, 645, 745, 935, 945, 955, 965, 970)
- Instinct series (2, 3, E, Crossover)
- MARQ series (1, 2, Adventurer, Athlete, Aviator, Captain, Commander, Driver, Expedition, Golfer)
- Venu series (1, 2, 3, 4, D, Sq, Sq2, X1)
- Vivoactive series (3, 4, 5, 6)
- Enduro series (1, 3)
- Legacy Hero First Avenger, Legacy Saga Rey

## Code Patterns

### Drawing Operations
When modifying drawing code:
- Always multiply pixel values by `scale` for device-independent sizing
- Use `Graphics.COLOR_TRANSPARENT` as fill color when only drawing outlines
- Set pen width before drawing lines/circles
- Cache frequently accessed values (e.g., screen dimensions) in initialize/onLayout

### Color Scheme
Predefined colors define the cyberpunk aesthetic:
- Background: `0x0a0e27` (dark blue-black)
- Primary (time/accents): `0x00D4FF` (cyan)
- Secondary (date): `0x7b9aa8` (muted blue)
- Heart rate: `0xFF4D6A` (red-pink)
- Steps: `0x4DFFA6` (green)
- Battery: `0xFFD93D` (yellow)

### Performance Optimization
- Use `needsFullRedraw` flag to avoid unnecessary redraws of static elements
- `clearTimeArea()` only clears the minimal rectangle needed for time updates
- Sleep mode transitions (`onEnterSleep`/`onExitSleep`) trigger full redraws

## Configuration
Project configuration is in `monkey.jungle` (references manifest.xml) and `manifest.xml` (auto-generated, lists supported devices and metadata).
