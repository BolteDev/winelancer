#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "$WINEPREFIX/.corefonts-installed" ]; then
    winetricks -q corefonts
    touch "$WINEPREFIX/.corefonts-installed"
fi