# com.tara.passenger

Passenger app for the Taarraa taxi platform. See `../.agent/` in the parent
`pu_taxi_system/` repo for the modernization plan, architecture target, and current status.
This file describes what's actually in the tree today, not an aspirational template.

## Actual architecture

This app started from the same generic "Clean Architecture + BLoC + get_it" boilerplate as
the Driver app, but never followed it: `flutter_bloc`, `get_it`, and `dartz` are all
declared in `pubspec.yaml` and completely unused (`grep` for `extends Bloc`, `GetIt`, or
`Either` usage returns nothing live). `core/errors/failures.dart` and
`core/usecases/{usecase,noparam}.dart` are dead scaffolding from that same abandoned
template. Treat any reference to it (including in old commit history or design docs) as
stale.

**The actual pattern is GetX only**, with a consistent screen-per-folder convention under
`lib/presentation/screens/<feature>/`:

- `binding.dart` — route-based DI (`Get.lazyPut`/`Get.put`)
- `logic.dart` — `GetxController` holding business logic
- `state.dart` — the screen's observable (`Rx`/`.obs`) fields
- `view.dart` — the UI, wired via `GetBuilder`/`Get.find`

Feature migration to the target shared architecture (`core/`, `services/`, dependency
injection via constructor rather than ad hoc `ClassName()` instantiation) is in progress —
see `.agent/PROGRESS.md` in the parent repo for what's done, and
`.agent/skills/architecture.md` for the target end-state.

## Secrets

Runtime secrets are compiled in via `--dart-define-from-file`, not hardcoded. Copy
`dart_defines.example.json` to `dart_defines.json`, fill in real values, then:

```sh
flutter run --dart-define-from-file=dart_defines.json
flutter build apk --dart-define-from-file=dart_defines.json
flutter build ios --dart-define-from-file=dart_defines.json
```

`dart_defines.json` is gitignored — never commit it. CI should inject it from a secrets
store at build time.

**Current coverage:** `GOOGLE_MAPS_API_KEY` and `GOOGLE_PLACES_API_KEY` are env-only.
**`baseUrlApi` and `socketBasedUrl` are still hardcoded literals** in
`core/utils/app_constant.dart` — not yet migrated to `--dart-define` (unlike the Driver
app, where these are already environment-overridable).

**This does not mean credential hygiene is resolved.** The *old* values that were
previously hardcoded in source (Google Maps key, Places key, Telegram bot token, a bearer
token) have been committed to this repo's history and a public-facing remote, and **have
not been rotated**. See `.agent/PLAN.md` Phase 0.1 in the parent repo — that's still
outstanding and is the single highest-priority open item independent of any feature work.

## Getting started

Standard Flutter project. Target Flutter `3.38.9` per `.fvmrc`, SDK `>=3.4.3 <4.0.0`.
`flutter analyze`'s analysis server is broken in this dev environment — use
`dart analyze <path>` instead (see `.agent/skills/flutter-dart.md`).
