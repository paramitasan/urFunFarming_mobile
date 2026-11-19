#!/usr/bin/env bash
# Local-only demo of the checked-out Flutter source and the sibling Django API.
set -euo pipefail
mobile=$(cd "$(dirname "$0")/.." && pwd -P)
parent=$(dirname "$mobile")
backend="$parent/urFunFarming"
if [[ ! -f "$backend/marketplace/api_urls.py" ]]; then
    echo "Expected the patched Django checkout in: $backend" >&2; exit 1
fi
prebuilt=""
if ! command -v flutter >/dev/null; then
    prebuilt="${MARKETPLACE_PREVIEW_DIR:-$HOME/Downloads/Marketplace-Checkpoint1/web-vorschau}"
    if [[ ! -f "$prebuilt/index.html" || ! -f "$prebuilt/main.dart.js" ]]; then
        echo "Flutter is not on PATH. Install Flutter or set MARKETPLACE_PREVIEW_DIR to web-vorschau from the extracted checkpoint ZIP." >&2
        exit 1
    fi
    echo "Flutter is not on PATH: using the downloaded group preview. The group menu in this preview is not part of your branch."
fi
command -v python3 >/dev/null || { echo "Python 3.10+ is required." >&2; exit 1; }
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else "Please use Python 3.10 or newer.")'
# These settings disable PWS/PostgreSQL and bind the preview to loopback.
export PRODUCTION=False DEBUG=True DJANGO_SETTINGS_MODULE=uff.settings
cd "$backend"
if [[ ! -x .venv/bin/python ]]; then python3 -m venv .venv; fi
py="$backend/.venv/bin/python"
"$py" -m pip install -r requirements-dev.txt
"$py" manage.py migrate --noinput
"$py" manage.py seed_demo
cd "$mobile"
if [[ -n "$prebuilt" ]]; then
    exec "$py" tool/preview_marketplace.py "$backend" --port "${1:-8000}" --web-dir "$prebuilt"
fi
flutter pub get
opts=(--no-pub --base-href /app/)
help_text=$(flutter build web --help --verbose)
if [[ "$help_text" == *web-resources-cdn* ]]; then opts+=(--no-web-resources-cdn); fi
if [[ "$help_text" == *pwa-strategy* ]]; then opts+=(--pwa-strategy=none); fi
flutter build web "${opts[@]}"
exec "$py" tool/preview_marketplace.py "$backend" --port "${1:-8000}"
