#!/bin/sh
set -e

git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter precache --web
flutter pub get
flutter build web --release
