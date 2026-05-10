#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

DISPLAY="${DISPLAY:-:99}"
export DISPLAY

XVFB_PID=""
APP_PID=""
CLEANED_UP=0

cleanup() {
    if [[ "$CLEANED_UP" -eq 1 ]]; then
        return
    fi

    CLEANED_UP=1

    echo "[runtime] Shutdown requested"

    if [[ -n "${APP_PID:-}" ]]; then
        echo "[runtime] Stopping app process..."
        kill -TERM "$APP_PID" 2>/dev/null || true
        timeout=15

        while kill -0 "$APP_PID" 2>/dev/null; do
            if [[ "$timeout" -le 0 ]]; then
                echo "[runtime] Force killing app process..."
                kill -KILL "$APP_PID" 2>/dev/null || true
                break
            fi

            sleep 1
            timeout=$((timeout - 1))
        done
    fi

    echo "[runtime] Stopping wineserver..."
    wineserver -k || true

    if [[ -n "${XVFB_PID:-}" ]]; then
        echo "[runtime] Stopping Xvfb..."
        kill "$XVFB_PID" 2>/dev/null || true
    fi

    echo "[runtime] Shutdown complete"
}

trap cleanup SIGTERM SIGINT

# Run Xvfb
echo "[runtime] Starting Xvfb..."

Xvfb "$DISPLAY" -screen 0 1024x768x16 &
XVFB_PID=$!

_waited=0
until xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; do
    if ! kill -0 "$XVFB_PID" 2>/dev/null; then
        echo "[runtime] Xvfb process died"
        exit 1
    fi
    _waited=$((_waited + 1))
    if [[ "$_waited" -ge 10 ]]; then
        echo "[runtime] Xvfb failed to start within timeout"
        exit 1
    fi
    sleep 1
done

/opt/runtime/init-wine.sh

for hook in /hooks/pre-start.d/*; do
    if [[ -x "$hook" ]]; then
        echo "[runtime] Running pre-start hook: $hook"
        "$hook"
    fi
done

if [[ "$#" -eq 0 ]]; then
    echo "[runtime] No application command provided"
    exit 1
fi

echo "[runtime] Launching application..."

"$@" &
APP_PID=$!

wait "$APP_PID"
EXIT_CODE=$?

for hook in /hooks/post-stop.d/*; do
    if [[ -x "$hook" ]]; then
        echo "[runtime] Running post-stop hook: $hook"
        "$hook"
    fi
done

cleanup

exit "$EXIT_CODE"
