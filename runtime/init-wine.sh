#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "$WINEPREFIX/.initialized" ]; then
    echo "[runtime] Initializing wine prefix..."

    wineboot --init
    touch "$WINEPREFIX/.initialized"

    echo "[runtime] Wine initialization complete"
fi