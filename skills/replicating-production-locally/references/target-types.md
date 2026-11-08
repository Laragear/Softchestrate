# Target types

Candidates below are categories to check, not confirmed tool choices. Verify the tool is installed, read its current docs and `--help`, and cite the URL before relying on any flag or behavior. Read only the section for your target type.

## Contents
- Web app / backend services
- iOS app
- Android app
- ESP32 / firmware daemon
- Network stack
- Linux driver / kernel code
- Desktop app
- CLI
- Wasm
- Framework / language package
- Software plugin
- Serverless / edge function
- Data pipeline / batch job
- Other

## Web app / backend services
Evidence: deploy manifests, compose or orchestration files, reverse proxy and TLS config, env var names, migrations, queue and cache definitions.
Replica boundary: every service and data store production runs, same versions, local placeholder secrets, local-only TLS if production terminates TLS.
Likely gaps: managed cloud services (stand-in), scale, real DNS and certificates, third-party APIs (stubs).
Candidate runtimes: a container engine already installed (rootless when possible).

## iOS app
Evidence: project and build settings, deployment target, entitlements, backend endpoint config per environment, push and auth provider config.
Replica boundary: the app build against a local replica of its backend; point the app at local endpoints through its own environment configuration.
Likely gaps: push notifications, App Store signing, device sensors, performance on real hardware.
Candidate runtimes: the platform vendor's simulator; requires the vendor's host OS, so check availability first.

## Android app
Evidence: Gradle build variants, manifest, min and target SDK, backend endpoint config, signing configs (names only).
Replica boundary: the app on an emulated device matching the target SDK and ABI, against a local backend replica.
Likely gaps: push services, vendor-specific OEM behavior, real device sensors, performance.
Candidate runtimes: the platform emulator; cleartext traffic to localhost may need the app's own debug network config.

## ESP32 / firmware daemon
Evidence: build config, partition table, board and chip variant, enabled peripherals, protocol and cloud endpoint config.
Replica boundary: the same firmware source and config, run in an emulator or on a dev board only with user approval; peers (broker, cloud endpoint) replicated locally.
Likely gaps: radio behavior, timing, real peripherals, flash wear. State which peripherals are unemulated.
Candidate runtimes: an emulator that supports the exact chip variant; confirm support before planning.

## Network stack
Evidence: topology definitions, routing and firewall config, service addresses, protocol versions, MTU, VLAN or overlay settings.
Replica boundary: the same topology as isolated virtual links and namespaces or VMs, same config files, same daemons and versions.
Likely gaps: real link characteristics (latency, loss), hardware offload, scale. Inject latency or loss only if production data shows it.
Never alter the host's own network configuration; isolate.

## Linux driver / kernel code
Evidence: kernel version and config, module build files, device tree or hardware ID tables, load parameters, userspace consumers.
Replica boundary: a VM running the production kernel version and config, with the module built and loaded inside the VM only.
Likely gaps: real hardware behavior, DMA and interrupt timing, firmware blobs. Use virtual or emulated devices where the hardware cannot be present, and list what is not exercised.
Never build-and-load on the host kernel.

## Desktop app
Evidence: build and packaging config, target OS and architecture matrix, installer and auto-update config, backend endpoint config per environment, permissions and entitlements, bundled runtime or framework version.
Replica boundary: the same build artifact for the production OS and architecture, run in a VM or container-like isolation, against a local replica of its backend and update server.
Likely gaps: code signing and notarization, OS-specific UI and permission prompts, GPU and display behavior, installer and update flow, other-OS targets.
Candidate runtimes: a VM matching the production OS version; a different host OS needs a VM or is a recorded gap.

## CLI
Evidence: build and release config, supported OS and architecture matrix, distribution channels (package registry, package manager, binary release), config file and env var names, exit codes, shell or runtime requirements.
Replica boundary: install the CLI the way users get it (the released or release-built artifact, not the source tree) in a clean, isolated environment, with its external services replicated locally.
Likely gaps: package manager and registry behavior, shell and terminal differences, OS-specific paths, interactive versus piped behavior.
Candidate runtimes: a clean container or VM per supported OS; check that the minimum supported runtime version is the one used.

## Wasm
Evidence: build target and toolchain config, host environment (browser, server runtime, edge runtime, embedded host), imported and exported interfaces, memory and feature flags, loader and glue code, hosting and caching headers.
Replica boundary: the same `.wasm` build run in the same kind of host production uses, served with the same headers, with host-provided imports backed by the same implementations or local stand-ins.
Likely gaps: host version differences, enabled proposals and feature support per host, performance, threading and shared-memory requirements (often depend on response headers), CDN behavior.
Candidate runtimes: the host named in the evidence; do not substitute a different host kind without recording it as a gap.

## Framework / language package
Evidence: package manifest, supported language and runtime version matrix, peer dependency ranges, build and publish pipeline, entry points and exports, consumer-facing install instructions.
Replica boundary: build the package as the publish pipeline does, publish it to a local registry or install from the built artifact, then consume it from a minimal project on each supported runtime version.
Likely gaps: real registry behavior and metadata, dependency resolution against newer versions published later, consumer toolchain variety, platform-specific native builds.
Candidate runtimes: a local registry or file-based install; one isolated environment per supported runtime version. Never publish to the real registry.

## Software plugin
Evidence: plugin manifest, declared host application and supported host versions, API or extension points used, packaging and distribution format, permissions requested, host configuration that loads it.
Replica boundary: the host application at the production version, with the plugin built and installed through its normal packaging path into an isolated profile or instance.
Likely gaps: marketplace review, signing and trust prompts, other host versions, interaction with other installed plugins, host data not present locally.
Candidate runtimes: the host's own isolated profile, sandbox or test-instance mechanism; confirm it exists in the host's docs and cite the URL.

## Serverless / edge function
Evidence: function definitions and triggers, runtime and version, memory and timeout limits, environment variable names, IAM or permission policies, event source mappings, routing and cold-start related config.
Replica boundary: the same function code and runtime version invoked with recorded or schema-valid events through the same trigger shape, with managed dependencies (queues, storage, databases) replicated locally.
Likely gaps: provider runtime internals, cold starts, concurrency and scaling, permission enforcement, provider-managed service behavior and limits.
Candidate runtimes: a local emulator from the provider, or the runtime image the provider documents; verify it supports the exact runtime version and cite the URL.

## Data pipeline / batch job
Evidence: job and schedule definitions, orchestrator config, source and sink definitions, schemas and migrations, runtime and library pins, retry, idempotency and backfill settings, resource limits.
Replica boundary: the same job code and orchestrator config run against local sources and sinks seeded with schema-faithful sample data, including one scheduled run and one retry or failure path.
Likely gaps: data volume and skew, upstream data quality, cluster scale and resource contention, managed service behavior, real credentials and network paths.
Candidate runtimes: the orchestrator production uses, run locally; if it cannot run locally, record the substitute as a gap. Use synthetic or anonymized data only, never production data.

## Other
Apply the same method: find rank 1 or 2 evidence, inventory components, same artifact first, isolate, verify with an end-to-end path, report gaps.
