#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -x .flutter-sdk/bin/flutter ]]; then
  export PATH="$PWD/.flutter-sdk/bin:$PATH"
fi
flutter build web --release
