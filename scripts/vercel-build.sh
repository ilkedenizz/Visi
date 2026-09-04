#!/bin/bash
set -e

echo "=== Installing Flutter SDK on Vercel ==="
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Checking Flutter Doctor ==="
flutter doctor

echo "=== Installing Dependencies ==="
flutter pub get

echo "=== Building Flutter Web for Vercel (Base Href '/') ==="
flutter build web --release --base-href "/"

echo "=== Vercel Build Finished Successfully ==="
