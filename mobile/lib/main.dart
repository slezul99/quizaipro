// Default entry point → development flavor.
// Use flavor-specific targets for CI and store builds:
//   flutter run  --flavor dev         -t lib/main_dev.dart
//   flutter run  --flavor staging     -t lib/main_staging.dart
//   flutter build apk --flavor production -t lib/main_production.dart
export 'main_dev.dart';
