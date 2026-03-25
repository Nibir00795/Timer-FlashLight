# Timer FlashLight — iOS App

A SwiftUI flashlight utility app for iPhone and iPad with a built-in auto-shutoff timer, SOS strobe mode, adjustable brightness, and a fullscreen color screen light. Built with AI-assisted development (Cursor + Figma MCP).

> **Note on development approach:** Swift/iOS code was generated and refined using Cursor agents through iterative prompting and Figma MCP for UI guidance. My role was product design, prompt engineering, architecture decisions, code review, and testing.

## Features

**Flashlight**
- One-tap on/off with smooth spark animation
- Adjustable intensity slider (0–100%) persisted across sessions
- Auto-flash on startup option

**Timer**
- Set a countdown (1 second – 1 hour) to auto-shutoff the flashlight
- Quick-access saved timer with one tap
- Sends the app to background when timer expires

**SOS Mode**
- Emergency strobe at 3 selectable speeds: 1×, 1.5×, 2×
- Automatically disables regular flashlight and timer

**Screen Light**
- Use the device screen as a colored light source
- 12 color presets (white, green, red, teal, orange, blue, cyan, purple, yellow, magenta, and more)
- Full brightness control with system brightness sync and restore
- Separate timer for auto-off
- First 3 colors free; full palette unlocked with premium

**Battery Monitor**
- Live battery percentage display with real-time notification-driven updates

**Settings**
- Auto-flash on startup toggle
- Notification preferences
- Rate, share, and more apps section

**Premium / Monetisation**
- Lifetime unlock via StoreKit 2 (non-consumable IAP)
- Banner ads (AdMob) for free users on main screen and screen light

## Tech Stack

| Area | Technology |
|---|---|
| Language | Swift 5 |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Reactive | Combine |
| Flashlight | AVFoundation (`AVCaptureDevice`) |
| Screen Brightness | UIKit (`UIScreen.brightness`) |
| Battery | UIKit (`UIDevice.batteryLevel`) |
| In-App Purchase | StoreKit 2 |
| Ads | Google AdMob (banner) |
| Persistence | UserDefaults |
| Platform | iOS / iPadOS (iPhone + iPad layouts) |

## Project Structure

```
Timer FlashLight/
├── App/
│   └── Timer_FlashLightApp.swift     # App entry point, scene lifecycle
├── Models/
│   ├── AppState.swift                # Shared app-level state
│   └── PremiumSheetPresenter.swift   # Paywall presentation logic
├── Services/
│   ├── FlashlightService.swift       # AVCaptureDevice torch control
│   ├── BrightnessService.swift       # UIScreen brightness management
│   ├── TimerService.swift            # Timer abstraction
│   ├── ScreenLightBrightnessStore.swift  # Brightness persistence for screen light
│   └── PurchaseManager.swift         # StoreKit 2 purchase + restore
├── ViewModels/
│   ├── HomeViewModel.swift           # Flashlight, timer, SOS, battery logic
│   ├── ScreenLightViewModel.swift    # Screen light color, timer, brightness
│   ├── MoreViewModel.swift           # Settings toggles, share, rate
│   └── ContentViewModel.swift        # Tab/navigation state
├── Views/
│   ├── HomeView.swift                # Main flashlight screen
│   ├── ScreenLightView.swift         # Fullscreen color light
│   ├── MoreView.swift                # Settings screen
│   ├── AccessPremiumView.swift       # Paywall / upgrade screen
│   ├── TimerBottomSheetView.swift    # Timer picker sheet
│   ├── ScreenLightTimerBottomSheetView.swift
│   ├── FlashlightOnAlertView.swift   # First-use flashlight alert
│   ├── PremiumFeatureAlertView.swift
│   └── Components/
│       └── BannerAdView.swift        # AdMob banner wrapper
└── Utilities/
    ├── Constants/
    │   ├── AppConstants.swift        # App IDs, layout, icon sizes, timer limits
    │   └── TimerSheetLayout.swift
    ├── Theme/
    │   └── AppTheme.swift            # Colors, typography, design tokens
    ├── Extensions/
    │   ├── View+Extensions.swift
    │   └── UIApplication+Suspend.swift
    └── Helpers/
        └── FontChecker.swift
```

## Requirements

- Xcode 16+
- iOS 17.0+ deployment target
- Physical device required for flashlight (torch not available in Simulator)

## Getting Started

1. Clone the repo and open `Timer FlashLight.xcodeproj` in Xcode
2. Select your development team in **Signing & Capabilities**
3. For AdMob, update `GADApplicationIdentifier` in `Info.plist` with your own app ID (test IDs are included for development)
4. For IAP, update `AppConstants.IAP.premiumLifetimeProductID` with your App Store Connect product ID
5. Build and run on a physical device

## App Store

[Timer FlashLight on the App Store](https://apps.apple.com/app/id6757694374)

## License

Private — all rights reserved.
