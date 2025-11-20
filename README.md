# Cyberpunk Watchface for Garmin

A futuristic cyberpunk-themed watchface for Garmin devices with customizable colors, progress arcs, and achievement indicators.

![Cyberpunk Watchface](https://img.shields.io/badge/Garmin-Connect%20IQ-00D4FF?style=flat-square)
![Build](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)

## Features

### Visual Design
- **Cyberpunk aesthetic** with neon colors and sleek design
- **Dual concentric circles** with hour markers at 12, 3, 6, and 9 positions
- **Decorative corner points** (hidden in "All Three" arc mode)
- **Gradient effects** on all text and icons for depth and style
- **Custom Orbitron font** for futuristic look

### Time Display
- **Large central time display** with hours and minutes
- **12/24-hour format** (configurable in settings)
- **Blinking seconds separator** (two dots)
- **AM/PM indicator** (in 12-hour mode)
- **Small seconds display** below main time
- **Date display** with day, date, and month (e.g., "WED 19 NOV")

### Health & Activity Metrics
- **Heart Rate** with ECG-style icon
- **Steps** displayed in thousands (e.g., "8.5K")
- **Battery Level** with icon and percentage
- **Achievement Stars** that appear when goals are reached:
  - Green star under steps when step goal is achieved
  - Pink star under heart rate when calorie goal is achieved

### Progress Arcs
Choose how you want to visualize your progress:
- **Battery Mode**: Single orange arc showing battery level
- **Steps Mode**: Single green arc showing step progress toward goal
- **Calories Mode**: Single pink arc showing calorie progress toward goal
- **All Three Mode**: Three distinct concentric arcs showing all metrics simultaneously
  - Outer arc (orange): Battery
  - Middle arc (green): Steps
  - Inner arc (pink): Calories

### Color Themes
Six cyberpunk-inspired color themes:
1. **Cyan Neon** (default) - Classic cyberpunk cyan and purple
2. **Purple Dreams** - Magenta and violet tones
3. **Green Matrix** - Matrix-inspired green theme
4. **Red Alert** - Aggressive red and orange
5. **Blue Ice** - Cool blue tones
6. **Orange Sunset** - Warm orange and yellow

### Customizable Settings
- **Time Format**: 12-hour or 24-hour
- **Progress Arc Data**: Choose between Battery, Steps, Calories, or All Three
- **Step Goal**: Set custom step target (1,000 - 50,000)
- **Calorie Goal**: Set custom calorie target (500 - 5,000)
- **Color Theme**: Six themes to choose from

## Supported Devices

This watchface supports 110+ Garmin devices including:

### Fenix Series
- Fenix 5, 5 Plus, 5S, 5X
- Fenix 6, 6 Pro, 6S, 6X
- Fenix 7, 7 Pro, 7S, 7X
- Fenix 8, 8 AMOLED
- Fenix Chronos, Fenix E

### Forerunner Series
- Forerunner 55, 165, 245, 255, 265, 570
- Forerunner 645, 745, 935, 945, 955, 965, 970

### MARQ Series
- MARQ (Gen 1 & 2)
- MARQ Adventurer, Athlete, Aviator, Captain, Commander, Driver, Expedition, Golfer

### Venu Series
- Venu, Venu 2, Venu 3, Venu 4
- Venu D, Venu Sq, Venu Sq 2
- Venu X1

### Other Series
- Instinct 2, Instinct 3, Instinct E, Instinct Crossover
- Vivoactive 3, 4, 5, 6
- Enduro, Enduro 3
- Legacy Hero First Avenger, Legacy Saga Rey
- And many more!

## Installation

### From Garmin Connect IQ Store
1. Open the **Garmin Connect IQ** app on your phone
2. Search for "**Cyberpunk**"
3. Tap **Install** and sync to your watch

### Manual Installation
1. Download the `.prg` file from the [Releases](../../releases) page
2. Copy to your device's `GARMIN\APPS` folder
3. Sync your device

## Development

### Prerequisites
- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- Visual Studio Code with Monkey C extension
- Java Runtime Environment

### Build Commands

**Using VS Code (Recommended):**
- Build: `Monkey C: Build for Device`
- Run Simulator: `Monkey C: Run`
- Export: `Monkey C: Export Project`

**Using Command Line:**
```bash
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true \
  -jar <SDK_PATH>/bin/monkeybrains.jar \
  -o bin/Cyberpunk.prg \
  -f monkey.jungle \
  -y <DEVELOPER_KEY_PATH> \
  -d <DEVICE_ID>
```

### Project Structure
```
Cyberpunk/
├── source/
│   ├── CyberpunkApp.mc        # Main application entry point
│   ├── CyberpunkView.mc       # Watchface view and rendering
│   └── CyberpunkBackground.mc # Background drawable
├── resources/
│   ├── fonts/                 # Orbitron custom fonts
│   ├── strings/
│   │   └── strings.xml        # Localized strings
│   └── settings/
│       ├── settings.xml       # Settings UI definitions
│       └── properties.xml     # Default property values
├── monkey.jungle              # Project configuration
└── manifest.xml               # Auto-generated manifest

```

## Technical Details

### Performance Optimizations
- Selective redrawing for battery efficiency
- Cached screen dimensions and scaling factors
- Device-independent sizing using scale factor
- Efficient arc rendering with minimal overdraw

### Color Scheme Architecture
All colors use RGB hex values with gradient effects:
- Background: Pure black (`0x000000`)
- Time display: Theme-dependent with light/mid/dark gradients
- Stats: Color-coded (heart rate, steps, battery) with gradients
- Glow effects: Subtle dark overlays (`0x1A1A2E`)

### Scaling System
All dimensions use a scale factor based on screen width:
```monkey-c
scale = screenWidth / 240.0
```
This ensures consistent layout across different Garmin device screen sizes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- **Design & Development**: Jean-Baptiste BAYLE
- **AI Assistant**: Claude Code (Anthropic)
- **Font**: Orbitron (custom implementation for Garmin)

## Changelog

### Version 1.0.0 (Current)
- Initial release with cyberpunk design
- Six color themes
- Three progress arc modes + "All Three" mode
- Achievement indicators for goals
- Customizable step and calorie goals
- Auto-updating settings
- Support for 110+ Garmin devices

## Support

For issues, questions, or feature requests, please open an issue on [GitHub](https://github.com/Mrjb14/Cyberpunk/issues).

---

**Enjoy your cyberpunk journey!** ⌚✨
