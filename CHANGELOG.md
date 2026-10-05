# Changelog

## 1.0.0 — 2026-10-05

- Add Flutter 3.47.6 and Dart 3.13.5 with Riverpod 3, go_router 18, appearance settings and disposable local notes for Android, iOS and web.
- Add responsive Liquid Glass surfaces with clipped blur, bright edges and soft wallpaper, plus an independent opaque Material 3 design option.
- Add standard Flutter styling or native Tailwind-like utilities through optional Mix 2.2.1 and experimental mix_winds 0.1.0-alpha.1, with separate locked dependency sets and all four choice combinations verified.
- Add a shared presentation kit, adaptive sidebar and compact navigation, opaque accessibility fallbacks, enlarged-text checks and selected-stack instructions for future AI agents.
- Keep env-driven public names and native identifiers, standard native hosts, isolated preview ports and project commands. Verified strict analysis, 17 unit/widget tests and release web builds for every combination, plus browser persistence, deletion and light/dark appearance.
- Native Android APK, iOS builds and device runs were not verified; they require Android SDK and full Xcode. Re-published the local development version as 1.0.0 at the owner request.
- Fix project commands printing a stack trace instead of a short message when .env or the web build is missing.
- Keep edited web/manifest.json fields; configuration now updates only the app names.
- Escape a leading @ or ? in the generated Android app name.
- Right-align the "Newest first" label of the notes list.
- Describe only the selected design and styling in AGENTS.md, SPEC.md and README.md.
- Correct the README: Flutter web loads CanvasKit and Roboto from Google's CDNs unless built with --no-web-resources-cdn.
