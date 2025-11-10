# Changelog - Built with Science

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.3.0] - 2024-11-09

### Added
- Flexible rest timer with 3 time options (60s, 75s, 90s)
- ChoiceChips UI for quick time selection
- User preference persistence for timer settings
- Modern circular timer display with visual indicators
- Skip button functionality during timer execution
- Color-changing timer (red for last 10 seconds)

### Changed
- Rest timer now managed internally by widget
- Improved timer UI with better visual feedback

### Fixed
- Rest timer properly continues in background
- Timer state restoration after app resume

## [4.2.0] - 2024-11-09

### Added
- Background timer functionality with BackgroundTimerService
- WidgetsBindingObserver for app lifecycle management
- 3x vibration pattern on timer completion
- Android 15 compatibility (AppLifecycleState.hidden support)
- State preservation when app goes to background
- Automatic workout state caching

### Fixed
- **CRITICAL**: App crash when switching to Spotify during workout
- Timer now continues running in background
- State properly restored when returning from background apps

## [4.1.0] - 2024-11-09

### Changed
- **MAJOR**: Implemented offline mode (Supabase temporarily disabled)
- All data now stored locally with SharedPreferences
- App operates 100% offline without cloud dependencies

### Added
- SUPABASE_STATUS.md with reactivation instructions
- Stub Supabase service for offline operation
- Main.dart backup for reference

### Fixed
- Compilation errors related to Supabase dependencies
- Authentication flow adapted for offline usage
- Statistics screen type errors
- Workout screen dependency issues

### Documented
- Complete offline mode documentation
- Step-by-step Supabase reactivation guide
- Backup and restore procedures

## [4.0.0] - 2024-09-16

### Added
- Complete persistence system with SharedPreferences
- Exercise variation persistence
- Weight and reps persistence across workouts
- Difficulty level persistence
- Notes system with persistence
- Intelligent caching (auto-save on set 3)

### Features
- 3-day Full Body program (A, B, C workouts)
- Complete SuperSets implementation with A1/A2/B1/B2 pattern
- YouTube video links for all exercises
- Exercise variations (4-6 options per exercise)
- Last workout data restoration
- Workout session tracking

### Fixed
- All SuperSet navigation issues
- Overflow issues in exercise cards
- Dropdown positioning and display
- State management across app lifecycle

## [3.7.0] - Previous Versions

### Fixed
- Text overflow in exercise names
- Dropdown overflow in SuperSet widgets
- Visual layout issues

## [3.0.0] - Previous Versions

### Added
- SuperSet navigation system
- A1/A2/B1/B2 pattern implementation

## [2.14.0] - Previous Versions

### Added
- UI improvements
- Dynamic sets/reps from CSV data
- Exercise-specific rep targets

## [2.0.0] - Initial Stable Version

### Features
- Basic workout tracking
- Exercise library
- Program selection
- User authentication
- Cloud sync with Supabase (later disabled)

---

## Version Naming Convention

- **4.x.x**: Offline mode era with background timer improvements
- **3.x.x**: Persistence and overflow fixes
- **2.x.x**: SuperSet implementation and UI improvements
- **1.x.x**: Initial development versions

## Notes

### APK Releases
All APK files are available in the `releases/` directory:
- v4.3: `BuiltWithScience_v4.3_TIMER_OPTIONS.apk`
- v4.2: `BuiltWithScience_v4.2_SPOTIFY_FIX.apk`
- v4.1: `BuiltWithScience_v4.1_OFFLINE_MODE.apk`
- v4.0: `BuiltWithScience_v4.0_COMPLETE_PERSISTENCE.apk`

### Known Issues
- Notifications removed (dependency conflicts with Android SDK 34)
- Some lint warnings present (non-critical)

### Future Plans
- Re-enable Supabase cloud sync
- Implement notification system with compatible package
- Add 4-day and 5-day workout programs
- Create female-specific workout variant

---

*Last updated: November 9, 2024*
