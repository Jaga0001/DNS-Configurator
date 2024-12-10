# DNS Configurator

## Platform Support
- Android
- Windows
- macOS
- Linux

## Setup Instructions
1. Clone the repository
2. Run `flutter pub get`
3. Build for specific platforms:
   - Android: `flutter build apk`
   - Windows: `flutter build windows`
   - macOS: `flutter build macos`
   - Linux: `flutter build linux`

## Platform-Specific Notes
- Android: Uses method channels for DNS modification
- Windows: Uses `netsh` command
- macOS: Uses `networksetup`
- Linux: Uses `nmcli`

## Permissions
Requires administrative/root privileges on most platforms.