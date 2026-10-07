# mobile_new — Architecture

Host project architecture. Generated with the `create-flutter-project`
skill; keep this file updated whenever a decision covered here changes.
Per-module documentation lives in [`docs/modules/`](modules/) (empty until
the first feature module is requested).

## Decisions taken for this project

| Topic | Decision |
|---|---|
| Platforms | iOS + Android (no Web/Desktop) |
| Folder / packages | Project `mobile_new`: root folder and root package `mobile_new`; host app folder and package `mobile_new_app` |
| Brand seed color | `#2F6EEA` — placeholder, to be replaced by the final brand color |
| App ID / Bundle ID | `com.example.mobile_new` / `com.example.mobileNew` — placeholders |
| Feature modules | None yet — created only when explicitly requested |
| Observability | Firebase Crashlytics (Analytics/Performance not integrated yet) |
| CI/CD | GitHub Actions, trunk-based |
| Health endpoint path | `/v1/health` — **placeholder**, to be replaced by the backend's real path (`_healthCheckPath` in `lib/bootstrap/dependency_injection.dart`) |

## 1. Monorepo structure

Single monorepo managed with **Melos + pub workspaces**.

```
mobile_new/
  pubspec.yaml                     ← workspace root + Melos config (`melos:` key)
  docs/
    architecture.md                ← this file
    modules/                       ← one file per feature module (none yet)
  mobile_new_app/                  ← host app + composition root (the only app)
  packages/
    core/                          ← pure Dart: ports + tech-free shared code
    adapter_http_dio/              ← ApiClient → DioApiClient
    adapter_db_sqlcipher/          ← LocalDatabaseFactory → SqlcipherLocalDatabaseFactory
    adapter_logging_crashlytics/   ← AppLogger → CrashlyticsAppLogger
    adapter_sync_workmanager/      ← SyncScheduler → WorkmanagerSyncScheduler
    adapter_prefs_shared_preferences/ ← AppPreferences → SharedPreferencesAppPreferences
    adapter_connectivity_connectivity_plus/ ← NetworkInterfaceMonitor → ConnectivityPlusNetworkInterfaceMonitor
    design_system/                 ← tokens, theme, reusable components
```

Ports and adapters at the package level:

```
feature modules ──► core (ports) ◄── adapter_* packages
                         ▲
host app ────────────────┴── binds each port to its adapter
```

- **`core` has no third-party dependencies** (pure Dart SDK, no Flutter).
  It holds the ports — `ApiClient`, `ApiError`, `LocalDatabase`,
  `LocalDatabaseError`, `LocalDatabaseFactory`, `DatabaseSchema`,
  `AppLogger`, `TokenProvider`, `SyncScheduler`, `AppPreferences` (+
  `AppThemeMode`), `LogoutCleanerRegistry`, `ClearableOnLogout`,
  `OutboxRegistry`, `SyncableOutbox`, `NetworkInterfaceMonitor`,
  `ReachabilityProbe`, `ConnectivityService` (+ `ConnectivityStatus`),
  `Failure` — and tech-free shared code that works only through ports:
  `DefaultLogoutCleanerRegistry`, `DefaultOutboxRegistry`,
  `OutboxSyncWorker`, `DefaultConnectivityService`, `SyncOrchestrator`.
- **One adapter package per port and technology**
  (`adapter_[port-area]_[technology]`): depends on `core` + one technology
  family only, contains only working implementations of `core` ports,
  translates third-party types at the boundary (`DioException` →
  `ApiError`, `DatabaseException` → `LocalDatabaseError`) and never depends
  on `get_it`. Only the host app depends on them.
- `core` and `design_system` are mandatory dependencies of every feature
  module. A feature module never imports another feature module (the
  authentication module included) nor an `adapter_*` package.
- Versioning is **independent** per package, via Conventional Commits.
- Melos (≥ 7) is configured under the `melos:` key of the root
  `pubspec.yaml`. Scripts use `exec:` so they run with
  `dart run melos <script>` without a global install:
  `analyze` and `test` (packages with a `test/` folder) over every package;
  `build:prod` scoped to `mobile_new_app`.

## 2. Host app — `mobile_new_app`

The single host app sits at the root, next to `packages/` — never inside
it, and with no `apps/` folder (the project has exactly one app). The root
stays a neutral workspace named after the project (`mobile_new`): its
`pubspec.yaml` holds only the workspace list and the Melos config, never
app dependencies. The app is named `[project]_app`, so the root and the app
never share a folder or package name. Everything under
`packages/` is a library; `mobile_new_app/` is the only package that produces
a binary and the only one allowed to depend on `adapter_*` packages.


- Flavors: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`, all
  delegating to `main_common.dart`; `main.dart` delegates to dev for
  tooling defaults.
  - Android: `productFlavors` with `applicationIdSuffix` (`.dev`,
    `.staging`) and a per-flavor `app_name` via `resValue`
    (`buildFeatures.resValues = true`).
  - iOS: configurations `Debug/Release/Profile-{dev,staging,prod}`, one
    shared scheme per flavor, per-configuration xcconfigs in
    `ios/Flutter/` and the Podfile map; Bundle IDs
    `com.example.mobileNew.dev`, `.staging` and `com.example.mobileNew`
    (prod), display names via `APP_DISPLAY_NAME`. The base configurations
    and the `Runner` scheme remain for Xcode tooling — always use
    `--flavor`.
  - Distinct icon/splash per flavor: **not done yet**.
- Run a flavor:
  `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json`
- `config/{dev,staging,prod}.json` hold `API_BASE_URL` (placeholders
  `https://api-dev.example.com`, …). Secrets never go in these files; they
  come from the CI provider's secrets.
- Minimum OS: iOS 15.0 (required by Firebase); Android uses Flutter's
  default `minSdk`.
- Build number must come from CI — never bumped by hand. **Not wired
  yet**: CI has no release build job, so nothing sets the build number
  today (see §12).

## 3. Dependency injection

- **get_it**. Composition root in `lib/bootstrap/dependency_injection.dart`.
- `_registerCoreAdapters` binds each `core` port to its adapter by the port
  type, plus `DefaultLogoutCleanerRegistry`, `DefaultOutboxRegistry` and
  `OutboxSyncWorker` (built with the registry and `AppLogger`),
  `DefaultConnectivityService` and `SyncOrchestrator`. It is
  the only place that knows which technology backs each port.
- Feature modules will add their `register[X]ModuleDependencies(getIt)`
  calls after it (authentication module first, once it exists).

## 4. Routing

- **go_router** (`lib/bootstrap/app_router.dart`). Until the first module
  exists, it holds only the host placeholder route `/` (`app.home`,
  `HomePage`, built with `design_system`'s `AppEmptyState`).
- Modules will expose their routes (`[module]ModuleRoutes`), namespaced as
  `[module].[screen]` / `/[module]/[screen]`.
- No auth guard yet: `redirect` + `refreshListenable` arrive with the
  authentication module.
- Deep linking (Universal Links on iOS, App Links on Android): **not
  configured yet** — no associated domains entitlement, no
  `intent-filter` with `autoVerify`, no `apple-app-site-association` /
  `assetlinks.json` on the backend.

## 5. Networking — `adapter_http_dio`

- `DioApiClient` with Auth (bearer token only when a `TokenProvider` is
  registered — none yet), Logging (method, path, status, duration through
  `AppLogger`; never headers or bodies) and Retry (exponential backoff +
  jitter, max 3 attempts, transient errors only, never 4xx) interceptors.
  No cache interceptor.
- `post`/`put`/`patch`/`delete` accept an `idempotencyKey`, sent as the
  `Idempotency-Key` header (kept on retries); outbox operations send their
  own id, so a resend is applied once by the backend.
- `DioReachabilityProbe`: `HEAD` to the health endpoint on its own Dio
  instance (no interceptors, 3 s timeout); any HTTP answer = reachable.
  Path `/v1/health` is a **placeholder** (see the decisions table).
- Base URL from `API_BASE_URL` (`--dart-define-from-file`).
- API versioning by URL path, **per module**: each feature module keeps
  its backend paths in its own `[Name]ApiPaths` (one `version` constant,
  e.g. `/v1`), so modules move to `/v2` independently. No shared API
  version in `core`.
- Android `network_security_config.xml`: cleartext disabled; the `dev`
  flavor overrides it to allow `10.0.2.2`/`localhost` only.

## 6. Local persistence — `adapter_db_sqlcipher`

- One encrypted database per module schema, all inside
  `<Application Support>/local_databases/` (`path_provider`; iOS
  `Library/Application Support`, Android the private `files` directory —
  never `Documents`, which the Files app can expose); random 256-bit key per database in
  `flutter_secure_storage` with `first_unlock_this_device` (never backed
  up nor migrated; readable by the background sync while the device is
  locked). Fresh installs run
  `createStatements`; upgrades run pending `migrations` in order.
- Android: `allowBackup="false"`, `fullBackupContent="false"` and
  `data_extraction_rules.xml` excluding everything from cloud backup and
  device transfer.
- iOS: `AppDelegate.swift` creates `Library/Application Support/local_databases`
  and marks it `isExcludedFromBackup` on every launch, before Dart runs
  (covers current and future files, `-wal`/`-journal` included).
  Verified on the iPhone 17 Pro simulator on 2026-10-06 (clean install):
  `Documents` empty, `xattr -l` on the folder shows
  `com.apple.metadata:com_apple_backup_excludeItem`.

### Preferences — `adapter_prefs_shared_preferences`

- `AppPreferences` (in `core`) → `SharedPreferencesAppPreferences`
  (`SharedPreferencesAsync`). Non-sensitive values only (theme,
  language) — never tokens, personal or business data.
- Defaults: `AppThemeMode.system`, no language until the user chooses.
- Read at boot right after DI (2 s timeout, fallback to the system
  theme). The host keeps a `ValueNotifier<ThemeMode>` fed by
  `themeModeChanges`, so a module saving a new theme applies it without
  restarting (`ValueListenableBuilder` around `MaterialApp.router`).
  `AppThemeMode` → `ThemeMode` mapping in
  `lib/bootstrap/app_theme_mode_mapping.dart`.
- The language is stored but not applied yet: `locale:` arrives with the
  first module with `l10n.yaml`.
- `sharedpref` is excluded from Android backup like every other domain.

## 7. Offline sync

- Conflict resolution is always **manual** (outbox + optimistic
  versioning, HTTP 409 → `sync_conflicts`). No CRDT, no backend-lock-in
  sync libraries, no side ever wins automatically.
- `WorkmanagerSyncScheduler` is registered but **not scheduled**: periodic
  sync starts once a feature module with an outbox exists.
  Each module with an outbox implements `SyncableOutbox`
  (`[Name]SyncableOutbox`, in its `adapters/driven/sync/`) and registers
  it in the `OutboxRegistry`; `OutboxSyncWorker` (in `core`) runs every
  registered outbox in isolation, logs failures by outbox name and
  returns whether something is left to retry (the background entry point
  returns that to workmanager). With no module registered it does
  nothing.
- Connectivity in three layers: `ConnectivityPlusNetworkInterfaceMonitor`
  (is there an interface?) → `DioReachabilityProbe` (does the backend
  answer? only asked when there is an interface) →
  `DefaultConnectivityService` (`unknown`/`offline`/`noInternet`/`online`,
  rechecking with backoff from 15 s to 5 min while `noInternet`). Started
  at boot, never awaited.
- `SyncOrchestrator` runs `OutboxSyncWorker` on every transition to
  `online` (2 s debounce, one run at a time). Registered but **not
  started** yet: `SyncOrchestrator.start()` arrives together with
  `schedulePeriodicSync()` and the first module with an outbox.
- Banner: `AppConnectivityBanner` (`design_system`) shown below every
  screen by `ConnectivityBannerHost` (`MaterialApp.router`'s `builder`)
  while `offline`/`noInternet` — never a modal. Placeholder English texts
  until the first module with l10n.
- Background entry point: `outboxSyncDispatcher`
  (`lib/bootstrap/background_sync.dart`); the host app never imports
  `workmanager`.
- iOS: `outbox_sync` registered in `AppDelegate.swift`
  (`WorkmanagerPlugin.registerPeriodicTask`) and in `Info.plist`
  (`BGTaskSchedulerPermittedIdentifiers`, `UIBackgroundModes: fetch`).

## 8. Design system — `packages/design_system`

Material 3 token system, structure inspired by SAP Fiori (Android).

| Piece | File |
|---|---|
| Colors (`ColorScheme.fromSeed`, fidelity, contrast 0.5) | `lib/tokens/app_color_scheme.dart` |
| Semantic colors (`ThemeExtension`) | `lib/tokens/app_semantic_colors.dart` |
| Typography (15 M3 styles, Inter bundled locally) | `lib/tokens/app_typography.dart` |
| Elevation (levels 0–4 + scrim) | `lib/tokens/app_elevation.dart` |
| Spacing (4dp grid) + margins | `lib/tokens/app_spacing.dart`, `lib/tokens/app_margins.dart` |
| Breakpoints (window size classes) | `lib/tokens/app_breakpoints.dart` |
| Shape (7 radius levels) | `lib/tokens/app_shape.dart` |
| Motion (durations, M3 curves, reduce-motion) | `lib/tokens/app_motion.dart` |
| Theme composition | `lib/app_theme.dart` |
| Components | `lib/components/app_empty_state.dart`, `lib/components/app_connectivity_banner.dart` |

- Inter 4.1 (SIL OFL, license in `assets/fonts/Inter-LICENSE.txt`) is
  bundled; text styles set `package: 'design_system'` so the host app
  resolves the packaged font.
- Never hardcode colors, spacing, radii or durations; never `Colors.*`.
  Components work in light/dark, adapt by window size class, and follow
  WCAG AA, `Semantics`, 48dp/44pt touch targets and dynamic font sizes.

## 9. Internationalization

- `gen-l10n`, one `l10n.yaml` + template ARB per feature module (none
  yet). The host app's placeholder texts are temporary.
- Language chosen manually by the user (never inferred from the system),
  persisted through `AppPreferences`.

## 10. Observability

- `AppLogger` → `CrashlyticsAppLogger` (breadcrumbs + non-fatal reports;
  console echo in debug).
- **Firebase is not configured yet**: run `flutterfire configure` (it
  generates `firebase_options.dart`, `google-services.json` and
  `GoogleService-Info.plist`, all git-ignored). Until then the boot falls
  back to console error reporting and the app still runs.
- Analytics events convention (once Analytics is added):
  `[module]_[object]_[action]`, snake_case, past tense.
- `FlutterError.onError` + `PlatformDispatcher.instance.onError` always
  configured; `ErrorWidget.builder` shows a friendly widget in non-debug
  builds.

## 11. Security

- No certificate pinning by default.
- Production builds use `--obfuscate --split-debug-info` (`build:prod`,
  Android app bundle only; no iOS production script yet).
- App Tracking Transparency: not needed until Analytics or another
  IDFA-accessing SDK is added.
- Root/jailbreak detection: warn + disable sensitive features, never block
  the whole app (not implemented yet).

## 12. CI/CD

- GitHub Actions (`.github/workflows/ci.yml`): `flutter pub get`,
  `dart run melos analyze`, `dart run melos test` on PRs and `main`.
- Renovate (`renovate.json`): auto-merge patches, manual review for majors.
- **Release pipeline: not created yet.** Pending: a release job that
  builds Android (`build:prod`) and iOS (no `--obfuscate` iOS script
  exists yet), sets the build number from the CI run number, signs both,
  and archives `build/debug-info` as a CI artifact so Crashlytics stack
  traces can be symbolicated.
- Secrets via `--dart-define-from-file` + CI secrets; never
  `flutter_dotenv`.

## 13. Boot sequence

Implemented in `mobile_new_app/lib/main_common.dart`:

1. `Firebase.initializeApp()` — 5 s timeout; on failure the boot
   continues without Crashlytics
2. App Tracking Transparency (iOS) — not needed yet
3. Global error handling
4. Dependency injection
5. Local preferences — theme read through `AppPreferences` (2 s timeout,
   fallback: system theme); language once a module with l10n exists.
   Then `ConnectivityService.start()`, never awaited
6. Remote Config — not integrated yet
7. Force Update check — not integrated yet
8. Terms re-consent — not applicable yet
9. `runApp()`
10. Deep links / auth redirect via go_router — auth redirect once an
    authentication module exists; Universal Links / App Links not
    configured yet (§4)

## 14. Governance

- New modules via the `create-flutter-module` skill and its wiring
  checklist, never copy/paste. No Mason brick (decided 2026-10-07): it
  would duplicate the skill's template and not do the host wiring.
- Package dependency rules to be enforced by a custom lint in CI (not
  created yet): no feature module imports another feature module or an
  `adapter_*` package; `core` has no dependencies; an `adapter_*` package
  depends only on `core` + one technology family and never on `get_it`.

## 15. Verification status (at creation)

- `dart run melos analyze`: no issues in all 7 packages.
- `dart run melos test`: 16 tests passing (core 1, design_system 2,
  adapter_http_dio 5, adapter_db_sqlcipher 3, adapter_logging_crashlytics 3,
  adapter_sync_workmanager 1, mobile_new_app 1).
- `flutter build apk --debug --flavor dev` and
  `flutter build ios --debug --no-codesign`: both succeed.
- Not yet run on a device/simulator (at creation).
- 2026-10-05, after adding `AppPreferences`: `melos analyze` no issues in
  all 8 packages; `melos test` 21 tests passing
  (adapter_prefs_shared_preferences 4, mobile_new_app 2, others
  unchanged); `flutter build apk --debug --flavor dev` succeeds. iOS
  build not re-run.
- 2026-10-05, after the outbox registry: `melos analyze` no issues;
  `melos test` passing (core 4).
- 2026-10-05, after connectivity + idempotency: `melos analyze` no issues
  in all 9 packages; `melos test` passing (core 9, adapter_http_dio 9,
  adapter_connectivity_connectivity_plus 3, design_system 4,
  mobile_new_app 3, …); `flutter build apk --debug --flavor dev` and
  `flutter build ios --debug --no-codesign` both succeed.
- 2026-10-06, after the iOS backup exclusion: `adapter_db_sqlcipher` 5
  tests; simulator build installed and launched (first run on a
  simulator), backup-exclusion attribute confirmed.
- 2026-10-07, iOS flavors: `flutter build ios --simulator --debug
  --flavor <f>` succeeds for `dev`, `staging` and `prod`; built
  `Info.plist` shows `com.example.mobileNew.dev` / `mobile_new dev`,
  `com.example.mobileNew.staging` / `mobile_new staging` and
  `com.example.mobileNew` / `mobile_new`. Not run on a device.
