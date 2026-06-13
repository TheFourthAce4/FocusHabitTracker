# FocusHabitTracker 🚀  
*A clean, motivational habit-tracking app built with SwiftUI, SwiftData, and MVVM.*

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
![Architecture](https://img.shields.io/badge/architecture-MVVM-green)

---

## 📌 Overview
**FocusHabitTracker** is a productivity app developed for **CSE 335 – Principles of Mobile Computing**.  
The app helps users build consistent habits through customizable schedules, location-enhanced tasks, and a motivational “Quote of the Day” fetched from a live Web API.

This project showcases:
- SwiftUI UI development  
- MVVM architecture  
- SwiftData local persistence  
- Web API integration (JSON decoding)  
- CoreLocation + MapKit usage  
- Multi-screen navigation and forms  

---

## ✨ Features

### 🗓 Habit Management
- Add habits with:
  - Daily / weekly / monthly / weekday frequency  
  - Date-range restrictions  
  - High-priority tagging  
  - Optional location attachment  
- Edit or delete habits anytime  
- Mark habits as completed  

### 📍 Location-Based Functionality
- Select a location using an interactive **MapPicker**  
- Attach GPS coordinates to specific habits  

### 🌤 Daily Motivation (Web API)
- Fetches a new **“Quote of the Day”** from ZenQuotes API  
- Uses `URLSession` + `JSONDecoder` (no third-party libraries)  

### 📊 Dashboard Insights
- Today’s habits due vs completed  
- Daily completion percentage  
- Per-habit total completions  
- Streak tracking  
- Recent activity log  

---

## 🏗 Architecture (MVVM)

The app follows Apple's recommended MVVM structure:
VIEWS
│── TodayView
│── AddHabitView
│── DashboardView
│── MapPickerView
│
VIEWMODELS
│── TodayViewModel (ObservableObject)
│── LocationService (ObservableObject)
│
MODELS
│── Habit (@Model)
│── HabitLog (@Model)
│── SwiftData ModelContainer
│
SERVICES
│── QuoteService (Web API)


Views are kept simple and reactive using:
- `@StateObject`  
- `@ObservedObject`  
- `@Query`  
- `@Environment(\.modelContext)`  

ViewModels expose:
- `@Published` state  
- Habit manipulation  
- JSON API handling  
- Location updates  

---

## 🛠 Technologies Used

- **SwiftUI**
- **SwiftData** (local persistence)
- **MVVM architecture**
- **CoreLocation & MapKit**
- **URLSession + JSONDecoder**
- **Async/Await**
- **NavigationStack / Sheets / Menus**

---

## 📄 License

This project is licensed under the **MIT License**.

---

## 👨‍💻 Author

**Abdullah Alghabban**  
Computer Science, Arizona State University  
CSE 335 – Principles of Mobile Computing

Feel free to explore the project, provide feedback, or contribute to future improvements.



