
# Hooks System

This directory contains optional runtime hooks executed by the reusable Wine runtime platform.

Hooks allow application-specific customization without modifying the shared runtime implementation.

The runtime automatically executes hooks during container startup and shutdown.

---

# Directory Structure

```text id="v3g0jp"
hooks/
├── pre-start.d/
└── post-stop.d/
```

---

# Hook Types


## pre-start.d

Executed after:

* Xvfb startup
* Wine initialization

but before:

* application launch

Typical use cases:

* winetricks installs
* registry modifications
* environment preparation
* runtime validation
* log setup

---

## post-stop.d

Executed after the application exits, but before final container cleanup completes.

Typical use cases:

* log archival
* cleanup
* metrics export
* crash dump collection
* diagnostics

---

# Execution Order

Hooks execute alphabetically.

Numeric prefixes are recommended to guarantee deterministic ordering.

Example:

```text id="l5vlh2"
10-corefonts.sh
20-vcrun2019.sh
30-registry-fixes.sh
```

Recommended ranges:

| Prefix Range | Purpose                    |
| ------------ | -------------------------- |
| 00–09        | bootstrap/environment      |
| 10–29        | Wine prerequisites         |
| 30–49        | registry/runtime tweaks    |
| 50–69        | application-specific setup |
| 70–89        | validation/checks          |
| 90–99        | finalization               |

---

# Hook Requirements

Hooks should:

* be executable
* use bash
* fail fast on errors
* remain idempotent where possible

Recommended template:

```bash id="i9v3h4"
#!/usr/bin/env bash
set -euo pipefail
```

Make executable:

```bash id="trt7c5"
chmod +x hooks/pre-start.d/example.sh
```

---

# Example Hook

Example: install Microsoft core fonts once.

File:

```text id="aqv1lg"
hooks/pre-start.d/10-corefonts.sh
```

Contents:

```bash id="eg8q2m"
#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "$WINEPREFIX/.corefonts-installed" ]; then
    echo "[hook] Installing corefonts..."

    winetricks -q corefonts

    touch "$WINEPREFIX/.corefonts-installed"
fi
```

---

# Important Design Principle

Hooks are intended for:

* application-specific behavior
* Wine prefix customization
* runtime extension

Hooks should NOT:

* replace runtime lifecycle management
* manage Xvfb
* supervise processes
* override shutdown behavior

Those responsibilities belong to the shared runtime platform.

---

# Failure Behavior

Hooks execute with:

```bash id="sljlwm"
set -euo pipefail
```

A failing hook will stop container startup.

This is intentional to prevent partially initialized runtime state.

---

# Runtime Lifecycle Order

Current runtime startup flow:

```text id="jlwmv9"
Start Xvfb
↓
Initialize Wine
↓
Run pre-start hooks
↓
Launch application
```

Shutdown flow:

```text id="jlwmwb"
Application exits
↓
Run post-stop hooks
↓
Cleanup runtime
↓
Shutdown wineserver
↓
Stop Xvfb
```

---

# Architectural Goal

The hooks system exists to keep:

```text id="jlwmwd"
generic runtime behavior
```

separate from:

```text id="jlwmwe"
application-specific customization
```

This allows the base runtime platform to remain reusable across multiple Wine-based applications.
