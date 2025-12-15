# iOS Widget Setup Guide

## Phase 9: Home Screen Widgets

This directory contains the iOS WidgetKit implementation for the Atomic Habits Hook App.

### Adding the Widget Extension in Xcode

Since iOS widget extensions require Xcode configuration, follow these steps:

#### Step 1: Open the iOS project in Xcode
```bash
cd ios
open Runner.xcworkspace
```

#### Step 2: Add Widget Extension Target
1. In Xcode, go to **File → New → Target**
2. Select **Widget Extension**
3. Name it `HabitWidget`
4. Uncheck "Include Configuration App Intent" (we use StaticConfiguration)
5. Click **Finish**

#### Step 3: Configure App Groups
1. Select the **Runner** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add **App Groups**
4. Add the group: `group.com.atomichabits.hook.widget`
5. Repeat for the **HabitWidget** target

#### Step 4: Replace Generated Widget Code
Replace the generated Swift files with the code from this directory:
- Copy `HabitWidget.swift` to the `HabitWidget` folder in your Xcode project

#### Step 5: Update Bundle Identifiers
- Main app: `com.atomichabits.hook` (or your bundle ID)
- Widget: `com.atomichabits.hook.HabitWidget`

#### Step 6: Configure Deployment Target
Ensure both targets have iOS 17.0+ as the minimum deployment target for modern WidgetKit features.

### How It Works

The widget uses:
- **UserDefaults** with App Groups for shared data between main app and widget
- **TimelineProvider** for periodic updates
- **Link** for deep linking back to the app on button tap
- **URL Scheme** `atomichabits://` for widget callbacks

### Data Flow

```
Flutter App                      iOS Widget
    │                               │
    ├─► HomeWidgetService          │
    │   └─► saveWidgetData()       │
    │       └─► UserDefaults ◄─────┤ getSnapshot()
    │           (App Group)        │
    │                              │
    ◄────────────────────────────── Link tap
         URL: atomichabits://complete_habit?id=xxx
```

### Files

- `HabitWidget.swift` - Main widget implementation (TimelineProvider, Widget View, Widget Configuration)
- `Info.plist` - Widget extension configuration
- `README.md` - This setup guide

### Testing

1. Build and run the app
2. Long-press on home screen → tap + → search "Habit"
3. Add the widget
4. The widget should display your current habit data
5. Tap "Complete" to mark habit as done
