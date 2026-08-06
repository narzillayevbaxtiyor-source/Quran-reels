<<<<<<< HEAD
# QuranReels

QuranReels - A TikTok-inspired Quran browsing app with beautiful recitations.

## Features

- Vertical full-screen feed (one verse per swipe)
- Beautiful full-screen backgrounds
- Quran Arabic text with Uthmani font
- Uzbek translation
- Audio recitation streaming
- Multiple reciters
- Bookmarks and favorites
- Search by surah, verse, or translation
- Dark and Light themes

## Architecture

- **Framework:** Flutter
- **State Management:** Riverpod
- **Architecture:** Clean Architecture
- **Navigation:** GoRouter
- **HTTP Client:** Dio
- **Local Storage:** Hive
- **Audio:** Just Audio
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics)

## Getting Started

### Prerequisites

- Flutter 3.16+
- Firebase project setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/quran_reels.git
cd quran_reels
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
```bash
flutterfire configure
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                     # Entry point
├── app.dart                      # Root App widget
├── core/                         # Core layer
│   ├── constants/               # App constants
│   ├── theme/                   # Theme configuration
│   ├── errors/                  # Error handling
│   ├── network/                 # HTTP client
│   └── utils/                   # Extensions
├── data/                         # Data layer
│   ├── models/                  # Data models
│   ├── repositories/           # Repository implementations
│   └── services/               # API, Local, Audio, Firebase services
├── domain/                       # Domain layer
│   └── entities/               # Domain entities
├── presentation/                 # Presentation layer
│   ├── providers/              # State management
│   ├── screens/                # Screen widgets
│   ├── widgets/                # Reusable widgets
│   └── routes/                 # GoRouter routes
└── di/                          # Dependency injection
```

## License

MIT
=======
# Quran-reels
>>>>>>> 72b72363ba45c1d9438a29751b342adc68ab903b
