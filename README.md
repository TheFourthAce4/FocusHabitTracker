# FocusHabitTracker

A habit-tracking iOS app built for CSE 335 – Principles of Mobile Computing at Arizona State University. Track daily routines, attach locations to habits, and stay motivated with a fresh quote every day.

---

## Features

**Habit management** — Create habits with flexible schedules (daily, weekly, monthly, or weekday), optional date ranges, priority flags, and attached GPS locations. Edit or delete habits anytime, and mark them complete as you go.

**Location-aware tasks** — Pin any habit to a real-world place using an interactive MapPicker. Coordinates are stored alongside the habit for future location-based extensions.

**Quote of the Day** — Pulls a fresh motivational quote from the ZenQuotes API on each launch using `URLSession` and `JSONDecoder` — no third-party dependencies.

**Dashboard** — At a glance: today's due vs. completed habits, daily completion percentage, per-habit totals, streaks, and a recent activity log.

---

## Architecture

Follows **MVVM**, Apple's recommended pattern for SwiftUI apps.

```
Views/
├── TodayView
├── AddHabitView
├── DashboardView
└── MapPickerView

ViewModels/
├── TodayViewModel       (ObservableObject)
└── LocationService      (ObservableObject)

Models/
├── Habit                (@Model – SwiftData)
├── HabitLog             (@Model – SwiftData)
└── ModelContainer

Services/
└── QuoteService         (ZenQuotes API)
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Mapping | CoreLocation + MapKit |
| Networking | URLSession + async/await |
| Architecture | MVVM |

---

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

## Getting Started

1. Clone the repo
2. Open `FocusHabitTracker.xcodeproj` in Xcode
3. Select a simulator or connected device running iOS 17+
4. Build and run (`⌘R`)

No API keys or external dependencies required.

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

## Author

**Abdullah Alghabban** — Computer Science, Arizona State University
