# Freelancer Wine Runtime Platform

Reusable Docker-based Wine runtime platform for running Windows server applications under Linux containers.

Initial target application:

* Freelancer FLServer

The architecture is designed to separate:

* generic Wine/container runtime behavior
* application-specific implementation
* debugging/tooling concerns

This allows the runtime layer to eventually support other Windows-based server applications without major architectural changes.

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

# Images

---

## dockerfile.base

Reusable Wine runtime platform.

Responsibilities:

* Wine lifecycle management
* Xvfb management
* signal handling
* graceful shutdown
* runtime hooks
* process supervision

This layer intentionally avoids application-specific behavior.

---

## dockerfile.flserver

Freelancer-specific application layer.

Responsibilities:

* Python runtime
* FLServer assets/configuration
* `fl.py`
* application launch logic

---

## dockerfile.flserver-debug

Optional diagnostics/debugging layer.

Potential tooling includes:

* VNC/X11 tooling
* network diagnostics
* tracing/debugging utilities

---

# Runtime Design

The runtime layer owns:

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

This keeps application logic separate from infrastructure/runtime orchestration.

---

# Hooks

Hooks allow application-specific runtime customization without modifying the shared runtime implementation.

Directory structure:

```text id="jlwms2"
hooks/
├── pre-start.d/
└── post-stop.d/
```

Examples:

* winetricks installs
* registry modifications
* runtime setup
* diagnostics collection

See:

```text id="jlwms3"
hooks/README.md
```

for details.

---

# Development Philosophy

This project intentionally favors:

* minimal upstream divergence
* reusable runtime behavior
* explicit lifecycle management
* production-oriented container behavior
* separation of concerns

The runtime layer should remain generic enough to support additional Wine-based applications in the future.

---

# Current Status

Current progress includes:

* reusable runtime platform
* graceful shutdown handling
* Wine lifecycle management
* hooks system
* Xvfb orchestration
* container supervision via `tini`

The FLServer application layer is currently under active development.

---

# Planned Features

* FLServer integration
* debug tooling image
* healthchecks
* persistent Wine prefixes
* structured logging
* operational hardening
* orchestration improvements

---

# Tooling

Recommended tooling:

* [Just Command Runner](https://just.systems/?utm_source=chatgpt.com)
* [ShellCheck](https://www.shellcheck.net/?utm_source=chatgpt.com)
* [Hadolint](https://github.com/hadolint/hadolint?utm_source=chatgpt.com)

---

# Repository Structure

```text id="jlwms4"
.
├── dockerfile.base
├── dockerfile.flserver
├── dockerfile.flserver-debug
│
├── runtime/
├── hooks/
├── flserver/
├── docs/
│
├── justfile
├── compose.yaml
│
├── .editorconfig
├── .gitattributes
├── .gitignore
└── .dockerignore
```

---

# Goals

* reusable Wine runtime platform
* clean separation of runtime vs application
* production-oriented lifecycle handling
* reusable architecture for future Windows services/apps under Wine
