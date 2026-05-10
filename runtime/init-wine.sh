#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/wineuser
export WINEPREFIX="${WINEPREFIX:-/home/wineuser/.wine}"

if [ ! -f "$WINEPREFIX/.initialized" ]; then
    echo "[runtime] Initializing wine prefix..."

    wineboot --init
    touch "$WINEPREFIX/.initialized"

    echo "[runtime] Wine initialization complete"
fi
