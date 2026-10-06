# mobile_new_app

Host app of the `mobile_new` monorepo: composition root (binds `core`'s
ports to the `adapter_*` packages), router, boot sequence and platform
setup. Feature modules live in `../packages/` and are wired in here.

Architecture: [`../docs/architecture.md`](../docs/architecture.md).

## Run

From the monorepo root, once: `flutter pub get`.

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=config/staging.json
flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=config/prod.json
```

`config/*.json` hold only non-secret values (`API_BASE_URL`); secrets come
from the CI provider.

## Firebase

Not configured yet. Run `flutterfire configure` (generates
`lib/firebase_options.dart`, `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist`, all git-ignored). Until then the
app boots without Crashlytics and reports errors to the console.

## Checks

From the monorepo root:

```bash
dart run melos analyze
dart run melos test
```
