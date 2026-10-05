# Flutter App

A fastDev mobile skeleton (`flutter-app`) for Android and iOS, with a web preview for agents and the owner.
Each project includes a small notes feature, appearance settings, checked-in package lock, strict analysis,
unit/widget tests, standard native hosts, configuration from `.env`, and detailed project agent instructions.

## Why this stack

- **Flutter stable + Dart**: official tooling and one UI implementation across mobile and the browser.
- **Riverpod 3 AsyncNotifier**: explicit dependency injection, async state and easily overridden dependencies.
- **go_router**: declarative routing and an explicit route table; recommended by Flutter's architecture guide.
- **Liquid Glass or Material 3**: responsive layouts, built-in accessible controls and theme support.
- **Flutter widgets (default) or Mix / Tailwind utilities**: an optional native utility adapter; actual
  Tailwind CSS cannot style Flutter widgets. The utility option pins Mix 2.2.1 and the experimental
  mix_winds 0.1.0-alpha.1, clearly labelled in the creation form and project docs.
  Standard Flutter is the recommended dependency-light default for agents.
- **Feature folders with controllers and repositories**: local changes have predictable boundaries.
  Flutter's [architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)
  support separation of UI/data, repository interfaces, immutable models and fake-based tests.
- **No initial code generator**: Riverpod [documents generation as optional](https://riverpod.dev/docs/concepts/about_code_generation).
  Ordinary Dart keeps the initial agent edit/check cycle short. Add generation if the project's models warrant it.
- **SharedPreferencesAsync**: modest, cross-platform demo storage and appearance. The package
  [does not promise durable critical storage](https://pub.dev/packages/shared_preferences); replace the notes
  adapter with Drift/SQLite or a real API when the product needs transactions, queries, synchronization or durability.

No backend, authentication, cloud vendor, HTTP framework or container runtime is imposed on every project.
Native mobile development needs host platform SDKs; Docker is not an alternative to Xcode or mobile devices.
The browser preview keeps verification useful without an emulator, while native builds remain explicit commands.

## Repository and release workflow

`template.toml` declares mobile metadata, tools, setup, commands, preview and Russian fastDev UI translations.
`files/` is the generated project, including conditional agent/spec documentation options.
The internal Dart package remains `app`; product name, storage namespace and native application IDs come from `.env`.
`CHANGELOG.md` and immutable `vX.Y.Z` tags are managed by fastDev. Use its draft → validate → verify → publish workflow.
Do not commit or tag by hand. Dependency updates are manual because fastDev currently supports npm updates only.

Tested toolchain: Flutter 3.47.6 (stable release tag), Dart 3.13.5. The project's `.fvmrc` records the SDK pin.
Verification executes locked setup, `check` and the release **web** build for all four combinations
of `ui = glass|material` and `styling = flutter|tailwind`. Conditional source and lockfiles select only
the chosen implementation. Regenerate lockfiles with `python3 scripts/generate-locks.py`; it works
in temporary folders and retains existing lock versions where constraints allow. Native Android/iOS hosts come from
`flutter create --platforms=android,ios,web --org com.example --project-name app --empty` with this SDK.
Native APK/iOS builds require additional SDKs, JDK/Xcode and distribution signing; see the release changelog
for what was actually verified on the publishing machine.
