#!/bin/bash

# 4. Install Melos
echo "Installing Melos..."
dart pub global activate melos

# 5. Run melos bootstrap
echo "Bootstrapping Melos packages..."
melos bootstrap

# 6. Run dart pub get for root project
echo "Running dart pub get in root project..."
dart pub get

echo "Setup complete!"
