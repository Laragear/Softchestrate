---
name: creating-devcontainers
description: "Creates and verifies a DevContainer for an existing project, inferring languages, package manager, services and tooling from cited repository evidence, and proves it works before reporting success. Use when asked to create, add, set up, generate, fix or update a devcontainer, dev container or .devcontainer. Not for empty projects, production Dockerfiles, deployments, CI pipelines or local dev servers."
license: MIT
compatibility: Needs shell and write access to the project, Podman (preferred) or Docker, the devcontainer CLI (npm @devcontainers/cli) or an orchestrator CLI for verification, and web access for latest versions.
---

# Creating DevContainers

Build a DevContainer from repository evidence and prove it works before reporting success. Never write application code or deploy; never edit production files unless the user says so.

Read `references/inference.md` before Phase 2, `references/config-rules.md` before Phase 4, `references/tooling.md` before Phase 5.

Terms: **receipt** = `path:line` or command output proving a fact. **artifact** = any file besides the devcontainer config (Dockerfile, Compose override, entrypoint, init script). **runtime** = the container engine. **driver** = the CLI that builds, starts and verifies.

## Hard rules

- No project: stop (Phase 1).
- No fact without a receipt. Unknown stays unknown: ask, never default.
- No success claim before Phase 5 passes.
- Production files (Dockerfile, Compose, CI) are read-only unless the user said otherwise.
- No multiline comments anywhere; comment only what is non-obvious, in one line.
- No secrets in any written file. Never read `.env`; only `.env.example`-style files.

## Procedure

Track: 1 Inspect, 2 Infer with receipts, 3 Choose the base, 4 Write, 5 Verify, 6 Report.

### 1. Inspect

Check the project files, the runtimes and CLIs on the host (`command -v podman docker devcontainer`), and the host UID and GID (`id -u`, `id -g`). Rootless evidence: `podman info --format '{{.Host.Security.Rootless}}'`; for Docker, `rootless` listed under Security Options in `docker info`. SELinux enforcing: `getenforce`.

- **No project:** stop with `STATUS: NEEDS_INPUT` and ask for it (path or files). Do not scaffold from a guess.
- **`.devcontainer.json` or `.devcontainer/devcontainer.json` exists:** ask once whether to update it, replace it, or add an alternative under `.devcontainer/<name>/`.

### 2. Infer with receipts

Build the receipts table (language and version, package manager, project type, deploy host, required services, system tooling) per `references/inference.md`. Conflicting receipts: apply its precedence, record the conflict, and ask if precedence does not settle it. A fact with no receipt goes to the user as one question through the question tool, else inline.

Latest version: look up the current stable tag from the image registry or official release page, cite the URL, then intersect with the project's constraint. If the latest violates a dependency constraint, take the highest version that satisfies it and record why.

### 3. Choose the base

1. Local environment files in the receipts (Compose, Sail, ddev, lando, nix, mise) decide services. Compose present means a Compose-based DevContainer.
2. Production Docker files present: ask whether to use them as the base to mirror production, recommended option first. If yes, extend without editing them (Compose override file, or `build.target`) and list every difference that cannot be equal.
3. Otherwise a Debian or Ubuntu official image per `references/config-rules.md`.

### 4. Write the files

Layout:
- Zero or one artifact: `./.devcontainer.json`, the artifact beside it.
- Two or more artifacts: `.devcontainer/devcontainer.json` with the artifacts inside `.devcontainer/`.
- Zed in the receipts (`.zed/` or `zed` on PATH): always the folder layout; Zed's docs name only `.devcontainer/devcontainer.json`.

Apply `references/config-rules.md` for image, user, UID and GID, Compose, ports, socat and lifecycle.

### 5. Verify

Pick runtime and driver per `references/tooling.md`, then, with the driver:

1. Build and start (`devcontainer up --workspace-folder <dir>`, adding `--docker-path podman` for Podman).
2. Run `id -u`, `id -g` and `id -un` inside (`devcontainer exec ...`) and compare with the host. The container user must not be root.
3. From inside, create a probe file in the workspace; on the host, check `stat -c '%u:%g'` equals the host `id -u:id -g`. Delete the probe.
4. Stop the container by its `devcontainer.local_folder=<workspace>` label unless the user wants it running.

On failure: fix, rebuild, rerun; the same error twice means stop and ask. Ownership is the arbiter: the probe must be owned by the host user's UID:GID on the host and the container user must not be root; a mismatch is a failure, never a warning. Container-side IDs are reported and may differ from the host's only when a user namespace maps them (Podman `keep-id:uid=,gid=`).

No runtime or driver reachable: validate the config with `devcontainer read-configuration` only, report `STATUS: PARTIAL`, and say nothing was started.

### 6. Report

Copy exactly. `OK` means every VERIFY line is PASS; `INVALID_BRIEF` means the request is not about a DevContainer.

```
STATUS: OK | PARTIAL | FAILED | NEEDS_INPUT | INVALID_BRIEF
PROJECT: <path> — type: <type> — receipt: <path:line>
FILES: <paths written>
RECEIPTS:
| Fact | Value | Source |
BASE: <image:tag> — latest-check: <url> — constraint: <receipt>
RUNTIME: <podman rootless | docker rootless | docker rootful> — driver: <name>
PRODUCTION MIRROR: <yes, via <file> | no> — DIFFERENCES: <list or "none">
VERIFY: <check — PASS|FAIL — evidence>
UID:GID: host <u:g> — container <u:g> — ownership <PASS|FAIL>
NEEDS FROM USER: <question + options, or "none">
```

## When to stop

Stop and ask when: the project is pristine; receipts conflict beyond precedence; a required fact has no receipt; no runtime exists; the same build or start error repeats; UID, GID or ownership cannot be made to match; a production file would need editing.
