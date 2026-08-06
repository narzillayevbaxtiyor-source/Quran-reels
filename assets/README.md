# Assets Directory

This directory contains all static assets for the QuranReels application.

## Directory Structure

```
assets/
├── fonts/         # Custom fonts (Uthmani Quran font)
├── images/        # App images and icons
└── audio/         # Bundled audio files (if any)
```

## Fonts

### Required Fonts

Place the following fonts in `assets/fonts/`:

1. **UthmanicHafs1.ttf** - Uthmani script Arabic font for Quran text
   - Download from: https://fonts.qurancomplex.gov.sa/
   - This is the primary Arabic text font used throughout the app

2. **UthmanicHafs1_Bold.ttf** - Bold variant
   - Used for surah names and headings

## Images

### Required Images

Place the following images in `assets/images/`:

1. **app_icon.png** (1024x1024) - Main app icon
2. **app_icon_foreground.png** (1024x1024) - Adaptive icon foreground
3. **splash_logo.png** (512x512) - Splash screen logo

## Audio

Audio files are streamed from CDN and not bundled with the app.
The `assets/audio/` directory is reserved for future offline support.

## Notes

- All font and image assets must be added to the `pubspec.yaml` assets section
- The Uthmani font is required for proper Quran Arabic text rendering
- For development, placeholder assets can be used
