# Freelancer Wine Runtime

Reusable Docker-based Wine runtime platform for running Windows server applications under Linux containers, in this case Microsoft Freelancer (2003) FLServer.

Includes:
* Generic Wine/container runtime behavior
* Application-specific implementation
* Debugging/tooling concerns

Can be re-used for other Windows applications with minimal changes (by using hooks or basing your runtime layer as a seperate dockerfile etc)

---

# Architecture

```text id="jlwms0"
scottyhardy/docker-wine:latest
            ↓
    dockerfile.base
            ↓
    dockerfile.flserver
            ↓
dockerfile.flserver-debug
```

---

## dockerfile.base

* Wine lifecycle management
* Xvfb management
* signal handling
* graceful shutdown
* runtime hooks
* process supervision

This layer avoids app-specific behavior.

---

## dockerfile.flserver

Freelancer-specific application layer.

* Python runtime
* FLServer assets/configuration
* `fl.py`
* Application launch logic

---

## dockerfile.flserver-debug

Optional diagnostics/debugging.

* VNC/X11 tooling
* Network diagnostics
* Tracing/debugging utilities

---

# Runtime Design

* Xvfb startup/shutdown
* Wine initialization
* graceful shutdown handling
* signal propagation
* wineserver cleanup
* hook execution

Applications are launched through the runtime using:

```dockerfile id="jlwms1"
CMD [...]
```


# Hooks

Hooks allow application-specific runtime customization without modifying the shared runtime.

Directory structure:

```text id="jlwms2"
hooks/
├── pre-start.d/
└── post-stop.d/
```

Examples:

* Winetricks installs
* Registry modifications
* Runtime setup
* Diagnostics collection

See:

```text id="jlwms3"
hooks/README.md
```
for details.

---

# Current Status

* Reusable runtime platform
* Graceful shutdown handling
* Wine lifecycle management
* Hooks
* Xvfb orchestration
* Container supervision via `tini`

---

# Planned Features

* FLServer integration
* Debug tooling image
* Healthchecks
* Persistent Wine prefixes
* Structured logging
* Operational hardening
* Orchestration improvements

---

# Tooling

Recommended tooling:

* [Just Command Runner](https://just.systems/?utm_source=chatgpt.com)
* [ShellCheck](https://www.shellcheck.net/?utm_source=chatgpt.com)
* [Hadolint](https://github.com/hadolint/hadolint?utm_source=chatgpt.com)

---
