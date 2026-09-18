#!/bin/bash
set -e

# Use the FVM-pinned Dart SDK so the setup honors .fvmrc.
if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found on PATH. Install FVM and run './setup.sh' again." >&2
  exit 1
fi

# Install the Flutter SDK pinned in .fvmrc.
echo "Installing the Flutter SDK via fvm..."
fvm install

# Create the local environment file without overwriting developer changes.
env_example="flutter_common/lib/envs/.env.local.example"
env_local="flutter_common/lib/envs/.env.local"
[ -e "$env_local" ] || cp "$env_example" "$env_local"

# Install Melos via the pinned SDK.
echo "Installing Melos via fvm dart..."
fvm dart pub global activate melos

# Bootstrap Melos packages via the pinned SDK.
echo "Bootstrapping Melos packages via fvm exec melos..."
fvm exec melos bootstrap

# Run dart pub get for the root project via the pinned SDK.
echo "Running fvm dart pub get in root project..."
fvm dart pub get

# Configure Git to use the tracked hooks.
echo "Configuring Git hooks via fvm exec melos..."
fvm exec melos setup

echo "Setup complete!"
