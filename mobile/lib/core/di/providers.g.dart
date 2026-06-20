// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'41b2f25c76b6f83a2fce321c1ea59a97cf24b60a';

/// Overridden in [ProviderScope] inside bootstrap.dart.
/// The override provides the [AppDatabase] instance created after
/// [getApplicationDocumentsDirectory] resolves.
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$hiveServiceHash() => r'3050484279dd4ec9221444627183bd91a635ae43';

/// See also [hiveService].
@ProviderFor(hiveService)
final hiveServiceProvider = Provider<HiveService>.internal(
  hiveService,
  name: r'hiveServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hiveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HiveServiceRef = ProviderRef<HiveService>;
String _$secureStorageHash() => r'313c8ea380a41eea1dbadead25d101f3c08cb231';

/// See also [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<SecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<SecureStorage>;
String _$networkInfoHash() => r'5bd78ba66ee52e6b221aa6f9bf302d4fea97c4e4';

/// See also [networkInfo].
@ProviderFor(networkInfo)
final networkInfoProvider = Provider<NetworkInfo>.internal(
  networkInfo,
  name: r'networkInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$networkInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkInfoRef = ProviderRef<NetworkInfo>;
String _$dioHash() => r'f8c4b3561b317cac55e6f264cb9dc7d14ebd7988';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$sseDioHash() => r'0fa13f6a1b0918eb3f3e4804cf09ef4a48781631';

/// Dedicated Dio instance for SSE (AI Tutor streaming).
/// Uses [ResponseType.stream] and a 5-minute receive timeout.
///
/// Copied from [sseDio].
@ProviderFor(sseDio)
final sseDioProvider = Provider<Dio>.internal(
  sseDio,
  name: r'sseDioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sseDioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SseDioRef = ProviderRef<Dio>;
String _$themeModeHash() => r'84eedbcba6a18f8f8ee2273c180123427e2b885a';

/// See also [themeMode].
@ProviderFor(themeMode)
final themeModeProvider = Provider<ThemeMode>.internal(
  themeMode,
  name: r'themeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeModeRef = ProviderRef<ThemeMode>;
String _$languageCodeHash() => r'b682e10213b42c5808de6dc45214bb8b3279cbda';

/// See also [languageCode].
@ProviderFor(languageCode)
final languageCodeProvider = Provider<String>.internal(
  languageCode,
  name: r'languageCodeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$languageCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LanguageCodeRef = ProviderRef<String>;
String _$appFlavorHash() => r'd4743a2799487ee88b3cdc7df0db9e7fd27ac4d4';

/// See also [appFlavor].
@ProviderFor(appFlavor)
final appFlavorProvider = Provider<String>.internal(
  appFlavor,
  name: r'appFlavorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appFlavorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppFlavorRef = ProviderRef<String>;
String _$onboardingCompletedHash() =>
    r'2687fb3cf66cae1130977212cad3e9a366c92c38';

/// See also [onboardingCompleted].
@ProviderFor(onboardingCompleted)
final onboardingCompletedProvider = AutoDisposeProvider<bool>.internal(
  onboardingCompleted,
  name: r'onboardingCompletedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingCompletedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingCompletedRef = AutoDisposeProviderRef<bool>;
String _$connectivityStreamHash() =>
    r'099c4c91d8bbeff762c86aad3cf420a75ed7c9a4';

/// See also [connectivityStream].
@ProviderFor(connectivityStream)
final connectivityStreamProvider = StreamProvider<bool>.internal(
  connectivityStream,
  name: r'connectivityStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStreamRef = StreamProviderRef<bool>;
String _$isConnectedHash() => r'a62b66d445f8634047ac1f080880b4ea0a17c178';

/// See also [isConnected].
@ProviderFor(isConnected)
final isConnectedProvider = AutoDisposeFutureProvider<bool>.internal(
  isConnected,
  name: r'isConnectedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isConnectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsConnectedRef = AutoDisposeFutureProviderRef<bool>;
String _$dailyGoalHash() => r'77840c4fa3f63c8c68de6174880c4914455be3ba';

/// See also [dailyGoal].
@ProviderFor(dailyGoal)
final dailyGoalProvider = AutoDisposeProvider<int>.internal(
  dailyGoal,
  name: r'dailyGoalProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dailyGoalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyGoalRef = AutoDisposeProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
