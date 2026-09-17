#!/bin/bash
set -e

# Use the FVM-pinned Dart SDK so the setup honors .fvmrc.
# This must be run after `fvm install` from CONTRIBUTING.md step 3.
if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found on PATH. Install FVM and run 'fvm install' first." >&2
  exit 1
fi

# 4. Resolve root dependencies via the pinned SDK
echo "Running fvm dart pub get in root project..."
fvm dart pub get

# 5. Bootstrap Melos packages via the lockfile-resolved package
echo "Bootstrapping Melos packages via fvm dart run melos..."
fvm dart run melos bootstrap

echo "Setup complete!"
