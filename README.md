# Just Music

A free, offline-first music player for Android and iOS, built with Flutter. No ads, no login, no premium tier — just your local music library.

## Features

- **Offline playback** — scans and plays music stored on your device, no internet required
- **Background playback** with lock-screen controls (play/pause/skip, seek)
- **Sleep timer** — stop playback after a chosen duration or at a specific time
- **Shuffle & repeat** — off / repeat-one / repeat-all
- **Playlists** — create, rename, delete, and manage custom playlists
- **Auto playlists** — Favorites, Recently Played, Recently Added, Most Played
- **Library browsing** — by song, album, and artist, with search and sort
- **Customizable look** — light/dark/AMOLED themes, accent colors, adjustable font size

## Tech stack

- **Flutter** + **Provider** for state management
- **just_audio** / **audio_service** for playback and background/notification controls
- **on_audio_query** for device music library scanning
- **sqflite** for local playlist storage, **shared_preferences** for settings

## Getting started

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

## Author

Built by [Prabin Sharma](mailto:sharmaprabin160@gmail.com).
