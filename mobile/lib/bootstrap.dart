import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:quizaipro_mobile/app.dart';
import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';

Future<void> bootstrap({
  required AppConfig config,
  required FirebaseOptions firebaseOptions,
}) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      debugPrint('[STARTUP-DIAG] 01 WidgetsFlutterBinding.ensureInitialized: done');

      AppConfig.initialize(config);
      debugPrint('[STARTUP-DIAG] 02 AppConfig.initialize: done '
          '(flavor=${config.flavor}, apiBaseUrl=${config.apiBaseUrl})');

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ));

      // Firebase is a SOFT dependency. Crashlytics/Analytics are non-essential —
      // the app's core (decks, study, AI) runs on the REST API + local Drift DB.
      // If Firebase fails to init (e.g. placeholder dev credentials, no network),
      // we must NOT let the exception bubble up: runZonedGuarded would catch it
      // and runApp() below would never be reached, leaving the app stuck on the
      // native splash forever. So guard it and degrade gracefully.
      debugPrint('[STARTUP-DIAG] 03 Firebase.initializeApp: starting...');
      try {
        await Firebase.initializeApp(options: firebaseOptions);
        debugPrint('[STARTUP-DIAG] 04 Firebase.initializeApp: done');

        final crashlytics = FirebaseCrashlytics.instance;
        await crashlytics.setCrashlyticsCollectionEnabled(
          config.enableCrashlytics,
        );

        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          if (config.enableCrashlytics) {
            crashlytics.recordFlutterFatalError(details);
          }
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          if (config.enableCrashlytics) {
            crashlytics.recordError(error, stack, fatal: true);
          }
          return true;
        };
      } catch (e, st) {
        // Keep the default Flutter error presenter so we still see errors in logs.
        FlutterError.onError = FlutterError.presentError;
        debugPrint('[STARTUP-DIAG] 04 Firebase.initializeApp: FAILED — '
            'continuing without Firebase (crashlytics/analytics disabled): $e\n$st');
      }

      await Hive.initFlutter();
      await _openHiveBoxes();
      debugPrint('[STARTUP-DIAG] 05 Hive: boxes opened');

      final dbDir = await getApplicationDocumentsDirectory();
      final database = AppDatabase(dbDir.path);
      debugPrint('[STARTUP-DIAG] 06 AppDatabase: created');

      debugPrint('[STARTUP-DIAG] 07 runApp: calling...');
      runApp(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
          ],
          child: const App(),
        ),
      );
    },
    (error, stack) {
      // Guard the Crashlytics call: if Firebase failed to initialize,
      // FirebaseCrashlytics.instance itself throws — which inside the zone's
      // own error handler would mask the original error.
      try {
        if (config.enableCrashlytics) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
      } catch (_) {/* Firebase unavailable — log-only fallback below */}
      debugPrint('[FATAL] Uncaught error: $error\n$stack');
    },
  );
}

Future<void> _openHiveBoxes() async {
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.settingsBox),
    Hive.openBox<dynamic>(AppConstants.featureFlagsBox),
    Hive.openBox<dynamic>(AppConstants.marketplaceListingsBox),
    Hive.openBox<dynamic>(AppConstants.draftsBox),
    Hive.openBox<dynamic>(AppConstants.libraryBox),
  ]);
}
