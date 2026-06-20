import 'package:quizaipro_mobile/bootstrap.dart';
import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/firebase/firebase_options_production.dart';

void main() => bootstrap(
      config: AppConfig.production,
      firebaseOptions: DefaultFirebaseOptionsProduction.currentPlatform,
    );
