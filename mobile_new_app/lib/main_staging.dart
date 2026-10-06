import 'bootstrap/app_flavor.dart';
import 'main_common.dart';

/// flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=config/staging.json
Future<void> main() => mainCommon(flavor: AppFlavor.staging);
