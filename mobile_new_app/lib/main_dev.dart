import 'bootstrap/app_flavor.dart';
import 'main_common.dart';

/// flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
Future<void> main() => mainCommon(flavor: AppFlavor.dev);
