#!/usr/bin/env python3
"""Regenerate both styling lockfiles outside the skeleton files tree."""
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
for option in ("flutter", "tailwind"):
    with tempfile.TemporaryDirectory(prefix="fastdev-flutter-lock-") as directory:
        scratch = Path(directory)
        manifest = root / "files" / f"pubspec.yaml@styling={option}"
        lock = root / "files" / f"pubspec.lock@styling={option}"
        shutil.copy2(manifest, scratch / "pubspec.yaml")
        if lock.exists():
            shutil.copy2(lock, scratch / "pubspec.lock")
        subprocess.run(["flutter", "pub", "get"], cwd=scratch, check=True)
        shutil.copy2(scratch / "pubspec.lock", lock)
