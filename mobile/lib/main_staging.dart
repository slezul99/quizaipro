import 'package:quizaipro_mobile/bootstrap.dart';
import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/firebase/firebase_options_staging.dart';

void main() => bootstrap(
      config: AppConfig.staging,
      firebaseOptions: DefaultFirebaseOptionsStaging.currentPlatform,
    );
