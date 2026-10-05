# Flutter App skeleton — instructions for AI agents

This repository is a fastDev skeleton (`flutter-app`). It is not a project: fastDev copies `files/` into
new projects and renders `*.tmpl` files. Read the fastDev skeleton authoring guide first
(MCP tool `get_authoring_guide`, or `docs/skeleton-authoring.md` in the fastDev repository).

- Change `template.toml` and `files/` only; `files/AGENTS.md.tmpl` and `files/SPEC.md.tmpl` are the
  instructions of the future projects, not of this repository.
- Do not commit, tag or edit `CHANGELOG.md` by hand: validate, verify and publish through fastDev
  (`validate_skeleton`, `verify_skeleton`, `publish_skeleton`). Publishing commits, creates the
  `vX.Y.Z` tag, pushes and updates the registry.
- Never move or delete a published tag.
- Everything is written in English.

## Flutter-specific rules

- Do work in a scratch project, then copy source/config/lockfiles back without `.dart_tool`, `build`,
  `ephemeral`, local.properties, generated plugin registrants, Gradle caches or machine paths.
- Keep the internal pub package `app` stable. Configuration comes from `.env` through `tool/config.dart`;
  never bundle `.env`. Public defines are an allowlist. Test quoting, Unicode, dollars and app IDs.
- `shared_preferences` is explicitly disposable demo storage; do not describe it as a database.
- Pin packages and keep the official native host configurations aligned with the Flutter SDK pin.
  Update `.fvmrc`, manifest requirements/stack, docs and lockfile together when changing SDK versions.
- Verify runs strict analysis, unit/widget tests and the release web build. Native SDKs are separate;
  do not claim APK/iOS/device verification when only web has been checked. Record limitations on publish.
- Try the actual fastDev browser preview, persistence, theme and Stop before publishing.

- Design and styling are independent choices. Keep a common UI contract and feature logic. Cover all
  four combinations in verification; utility styling is experimental and never presented as full CSS.
- Regenerate both conditional lockfiles with `python3 scripts/generate-locks.py`. Run formatting in
  materialized scratch projects, then copy only source back; conditional filenames are not Dart paths.
