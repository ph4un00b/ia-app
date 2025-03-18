# app

When modifying the .env file, the generator might not pick up the change

- clean cache: `$ dart run build_runner clean`
- run generator: `$ dart run build_runner build --delete-conflicting-outputs`

# commands

- regenerate types: `$ dart run build_runner build --delete-conflicting-outputs`
- create icons: `$ dart run flutter_launcher_icons`
- create splash: `$ dart run flutter_native_splash:create`
- create ios flavors: `$ clear; dart run flutter_flavorizr -p assets:download,assets:extract,ios:podfile,ios:xcconfig,ios:buildTargets,ios:schema,ios:plist,ios:dummyAssets,ios:icons,assets:clean`
- run dev app: `$ flutter run --flavor dev -t lib/main_dev.dart`
- run prod app: `$ flutter run --flavor prod -t lib/main_prod.dart`

# tests

- reminders: `$ clear; flutter test lib/features/Reminders`
- app init: `$ clear; flutter test lib/features/App/init.test.dart`

# clean ios
- `cd ios`
  - `rm -rf Podfile.lock Pods Runner.xcworkspace`
  - `pod deintegrate`
  - `pod install --repo-update`
  - `flutter clean`
  - `flutter pub get`

# todo

- [ ] router observing for logging <https://scribe.rip/@atefelsaid3/mastering-navigation-tracking-in-flutter-a-complete-guide-to-routeobserver-with-riverpod-ea23a12fb80c>
