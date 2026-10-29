#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
version="$(tr -d '\r\n' < .flutter-version)"
if [[ ! -x .flutter-sdk/bin/flutter ]]; then
  git clone --depth 1 --branch "$version" https://github.com/flutter/flutter.git .flutter-sdk
fi
.flutter-sdk/bin/flutter --version
.flutter-sdk/bin/flutter precache --web
.flutter-sdk/bin/flutter pub get
