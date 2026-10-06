import 'bootstrap/app_flavor.dart';
import 'main_common.dart';

/// flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=config/prod.json
Future<void> main() => mainCommon(flavor: AppFlavor.prod);
