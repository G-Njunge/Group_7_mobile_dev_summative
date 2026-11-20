# Hakikisha

Flutter + Firebase app (Android only) that verifies medicine packs against the official registry, flags counterfeit or recalled batches, and helps users find verified pharmacies.

- **Android package / applicationId:** `com.hakikisha.app`. Don't change it: Firebase and Google sign-in depend on it.
- The Flutter project lives in this `hakikisha_summative/` folder, not at the repo root. Run all `flutter` commands from here.

## Setup

### 1. Install the tools
| Tool | Version | Why |
|---|---|---|
| [Flutter](https://docs.flutter.dev/get-started/install) | 3.47.x stable (Dart 3.13.x) | Building and running the app |
| Android Studio (or Android SDK + **JDK 17**) | Latest | Android builds, emulators. The JDK comes bundled with Android Studio |
| An editor | VS Code with the **Flutter** and **Dart** extensions, or Android Studio with the **Flutter** plugin | |

Then check everything is green for Android:
```sh
flutter doctor
```
If it says *"No Java Development Kit (JDK) found"*, point Flutter at Android Studio's bundled JDK:
```sh
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"   # Windows; adjust the path on macOS/Linux
```

### 2. Get the code and run it
```sh
git clone <repo-url>
cd <repo-folder>/hakikisha_summative
flutter pub get
flutter run                 # on a connected Android device or a running emulator
flutter run -d chrome       # optional: quick UI checks in the browser
```
Open the `hakikisha_summative/` folder in your editor (or the repo root, since the Dart extension finds the project either way). Turn on **format on save** so `dart format` runs automatically.

### 3. Firebase (already connected, nothing to configure)
The app is connected to the Firebase project **`hakikisha-acd9a`** for Android (`com.hakikisha.app`) and web. These files are committed, so the app works right after `flutter pub get`:

| File | What it is |
|---|---|
| `lib/firebase_options.dart` | Firebase keys for each platform, used by `Firebase.initializeApp()` in `main.dart` |
| `android/app/google-services.json` | Android Firebase config |
| `firebase.json` | FlutterFire and Firebase CLI config |
| `firestore.rules`, `storage.rules` | Security rules for every collection and for photo uploads. See [docs/database.md](docs/database.md) |
| `firestore.indexes.json` | Composite indexes for the history and reports lists |

- **Don't run `flutterfire configure`.** It's already done. Running it again can register duplicate apps or overwrite these files. If you think it needs re-running, ask in the group first.
- **Console access:** you've been added as an Editor. Open the project at https://console.firebase.google.com/project/hakikisha-acd9a. Enabled so far: Email/Password sign-in and Firestore (production mode).
- **Deploying rules** (M5, or whoever is changing the rules) needs the Firebase CLI:
  ```sh
  npm install -g firebase-tools
  firebase login
  firebase deploy --only firestore:rules,firestore:indexes,storage --project hakikisha-acd9a
  ```
- **Storage** must be enabled in the console (Build → Storage) before report and profile photos can upload. New projects need the Blaze plan for Storage.
- **Google sign-in (later):** each person's debug SHA-1 has to be added in the Firebase console before Google sign-in works on their machine. Get it with `cd android && ./gradlew signingReport` (needs the JDK) and send it to M1.

### 4. Packages already added
Everyone's packages are already in `pubspec.yaml`, so you shouldn't need to edit it to start. If you do add a package, tell the group so two people don't edit `pubspec.yaml` at the same time.

- **App:** flutter_bloc, equatable, get_it, go_router, firebase_core, firebase_auth, cloud_firestore, firebase_storage, shared_preferences, mobile_scanner, image_picker, flutter_map, latlong2, geolocator, url_launcher
- **Tests:** bloc_test, mocktail, fake_cloud_firestore
- **`equatable` is pinned to 2.x on purpose.** `fake_cloud_firestore` doesn't support 3.x yet, so don't upgrade it.
- **Images** live in `assets/images/` (already registered in `pubspec.yaml`): `hakikisha-logo.png`, `login-abstract.png`, `bg-waves.png`.

### 5. Where your code goes
The folder skeleton already exists: `lib/core/` and `lib/features/<feature>/{data,domain,presentation}` with matching `test/features/<feature>/` folders. The `.gitkeep` files only exist so git keeps the empty folders. Delete one once its folder has a real file in it.

### 6. Backend: seed data and rules tests
The `backend/` folder is a small Node project (Node 20+, and Java 21+ for the emulators). It doesn't ship with the app.
```sh
cd backend
npm install
npm install -g firebase-tools
npm test                 # starts the Firestore + Storage emulators and runs the rules tests
npm run seed:emulator    # seeds medicines, batches and pharmacies into the emulator
```
To seed the real project, ask M5 for a service-account key. **Never commit it.**
```sh
GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json npm run seed
```
Demo codes from the seed (`backend/seed/seed-data.json`):

| Batch | Medicine | Expected result |
|---|---|---|
| `PA24-1150` | Panadol Advance 500mg | Genuine |
| `PA23-0871` | Panadol Advance 500mg | Flagged (recalled) |
| `CT24-0412` | Coartem 80/480 | Flagged (counterfeit) |
| `ZN23-0098` | Zinnat 500mg | Valid batch but expired |

### 7. Shared building blocks (`lib/core/`)
Use these instead of restyling. They follow the Figma file and support light and dark mode.

| Need | Use |
|---|---|
| Colours | `context.palette` (`brand`, `heading`, `text`, `textMuted`, `surface`, `danger`, …) |
| Screen frame with menu or back tile, title and waves background | `AppScaffold(title: ..., body: ...)` |
| Raised card / inset box | `NeuCard`, `NeuInset` |
| Buttons | `PrimaryButton(loading: ...)`, `SecondaryButton` |
| Form field with uppercase label and validator | `AppTextField` |
| Genuine/Flagged toggle, filter tabs | `SegmentedPill` |
| "RECENT SCANS" style heading | `SectionLabel` |
| Yes/no dialog (delete, withdraw) | `showConfirmDialog(...)` |
| Success / error feedback | `showAppSnackBar(context, msg, type: SnackType.success)` |
| Collection names and enum values | `FirestoreCollections`, `ScanResult`, `BatchStatus`, … |
| Routes | `AppRoutes.home`, … with `context.go` / `context.push` |
| Sign-out, session state | `context.read<SessionCubit>()` |
| User settings (scan sound, vibration, save history) | `context.read<SettingsCubit>().state.settings` |

**Translations:** add each new string to both `lib/core/l10n/app_en.arb` and `app_sw.arb`, then use `AppLocalizations.of(context).yourKey`. The Dart code is generated on `flutter pub get` / `flutter run` (or run `flutter gen-l10n`).

**Plugging in your feature:** in `lib/core/router/app_router.dart`, replace your `_placeholder(...)` with a `GoRoute` to your page. In `lib/core/di/injection.dart`, call your `register<Feature>Dependencies(sl)`.

**Tests:** `test/helpers/pump_app.dart` has `tester.pumpPage(widget)` (theme, localizations, router) and a `FakeSessionSource`.

_Screenshots will be added before submission._

## Team rules

### Architecture
- **State management:** `flutter_bloc`. Use Bloc for multi-step flows (auth, scan) and Cubit for simple screens. No `setState` for app state. Purely local UI state, such as a password visibility toggle, is fine.
- **No Firebase or business logic in `presentation/pages/` or `presentation/widgets/`.** UI only talks to its bloc.
- **Routing:** `go_router` with an auth redirect.
- **Dependency injection:** `get_it`. Repositories are lazy singletons. **Blocs are registered as factories**, so logout disposes them and no state leaks between users. Never create repositories inside widgets.
- **Design:** use the shared theme and widgets in `lib/core/` instead of restyling. Buttons are at least 48dp tall, and text contrast is at least 4.5:1.
- **Responsive:** wrap scrolling screens and forms in `SingleChildScrollView` or `LayoutBuilder`. Test on a small (5.5″) and large (6.7″) emulator and in landscape.

### Folder structure
```
lib/
  main.dart
  core/              theme, router, di, constants, shared widgets, utils
  features/
    auth/            M1
    scan/            M2
    history/         M3
    profile/         M3
    pharmacy/        M4
    report/          M4
    settings/        M5
      data/          datasources, models (fromJson/toJson), repositories (impl)
      domain/        entities, repository interfaces, usecases
      presentation/  bloc/, pages/, widgets/
test/
  features/<feature>/   unit + widget tests, mirroring lib/
```
Work mostly inside your own `lib/features/<feature>/` folder. If you need to touch shared files (`main.dart`, `pubspec.yaml`, `lib/core/`), tell the team first.

### Firestore contract
These field names are the contract. Use them exactly in models, security rules and the report.

| Collection | Fields (PK, FK) | Access |
|---|---|---|
| `users` | **uid (PK)**, fullName, email, phone, authProvider (`password` / `google`), photoUrl, createdAt | Owner only |
| `medicines` | **medicineId (PK)**, name, manufacturer, ppbRegNo, dosageForm, strength | Signed-in read, no client write |
| `batches` | **batchId (PK)**, *medicineId (FK)*, batchNumber, gtin, expiryDate, status (`valid` / `recalled` / `counterfeit`) | Signed-in read, no client write |
| `scans` | **scanId (PK)**, *userId (FK)*, *batchId (FK, null if not found)*, result (`genuine` / `flagged` / `notFound`), method (`camera` / `manual` / `upload`), scannedAt | Create / read / delete own; no update |
| `reports` | **reportId (PK)**, *userId (FK)*, *scanId (FK, optional)*, *pharmacyId (FK, optional)*, description, photoUrls, status (`pending` / `reviewed`), createdAt, updatedAt | Own only; update / delete while pending |
| `pharmacies` | **pharmacyId (PK)**, name, licenseNo, address, lat, lng, phone, verified | Signed-in read, no client write |

- The `users` doc ID is the Firebase Auth `uid`.
- Timestamps use `FieldValue.serverTimestamp()`. They can be `null` in the first local snapshot, so `fromJson` must handle null.
- Composite indexes: `scans (userId, scannedAt desc)` and `reports (userId, createdAt desc)`.
- Don't duplicate medicine data inside `scans`; reference it by `batchId`.

### Git workflow
- **Never push to `main`.** Use one branch per task: `feature/m2-scan-result`, `fix/m4-map-overflow`, `test/m1-auth-bloc`.
- Keep PRs small: one screen, one bloc, or one test file.
- Commit message format: `type(scope): summary`, for example `feat(scan): save scan result to Firestore` or `test(auth): add email validator tests`. Types: `feat`, `fix`, `test`, `chore`, `docs`, `refactor`.
- Every PR needs one approving review with a real comment. Review rotation: M1 → M2 → M3 → M4 → M5 → M1.
- Commit with the email linked to your GitHub account, or your commits won't count in Insights.
- Branch off `main`, or off your own unmerged branch if you're waiting on a review, then rebase onto `main` once it merges.

### Before opening a PR
GitHub Actions (`.github/workflows/ci.yml`) runs these on every PR, plus the security rules tests. Run them locally first so CI stays green:
```sh
dart format lib test
flutter analyze             # must show 0 issues
flutter test --coverage
```

### Testing
- Packages: `bloc_test`, `mocktail`, `fake_cloud_firestore`.
- Each member writes unit tests for their bloc or cubit and logic, plus at least one widget test for their screens.
- Blocs depend on repository **interfaces**, so tests mock the interface rather than Firebase.
