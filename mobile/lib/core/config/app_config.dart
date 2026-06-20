import 'app_flavor.dart';

class AppConfig {
  const AppConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.enableLogging,
    required this.enableAnalytics,
    required this.enableCrashlytics,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final bool enableLogging;
  final bool enableAnalytics;
  final bool enableCrashlytics;

  static AppConfig? _instance;

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig.initialize() must be called before accessing instance');
    return _instance!;
  }

  static void initialize(AppConfig config) {
    assert(_instance == null, 'AppConfig.initialize() must not be called more than once');
    _instance = config;
  }

  static const dev = AppConfig._(
    flavor: AppFlavor.dev,
    // Local QA: emulator's host-loopback alias reaches the Flask dev server
    // running on the host machine at localhost:5055.
    apiBaseUrl: 'http://10.0.2.2:5055/api/v1',
    wsBaseUrl: 'ws://10.0.2.2:5055/ws',
    enableLogging: true,
    enableAnalytics: false,
    enableCrashlytics: false,
  );

  static const staging = AppConfig._(
    flavor: AppFlavor.staging,
    apiBaseUrl: 'https://staging.quizaipro.com/api/v1',
    wsBaseUrl: 'wss://staging.quizaipro.com/ws',
    enableLogging: true,
    enableAnalytics: false,
    enableCrashlytics: true,
  );

  static const production = AppConfig._(
    flavor: AppFlavor.production,
    apiBaseUrl: 'https://quizaipro.com/api/v1',
    wsBaseUrl: 'wss://quizaipro.com/ws',
    enableLogging: false,
    enableAnalytics: true,
    enableCrashlytics: true,
  );

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProduction => flavor == AppFlavor.production;

  String get name => flavor.name;
}
