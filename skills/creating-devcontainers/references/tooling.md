# Runtime and driver selection

## Contents
- Runtime
- Driver
- Orchestrators and editors
- Reference CLI flags
- Sources

## Runtime

Take it from the Phase 1 host checks, in this order:

1. Podman reporting `host.security.rootless: true` in `podman info`: use it.
2. Docker listing `rootless` under Security Options in `docker info`: use it.
3. Docker rootful: proceed, and report that rootless was unavailable and why it is worth having.
4. Nothing reachable: Phase 5 degrades to config validation, `STATUS: PARTIAL`.

Rootless runs the engine as the host user, which costs nothing and limits what a container escape can reach. Point the driver at it with `--docker-path podman` (and `--docker-compose-path podman-compose` for Compose projects).

## Driver

Detect what the project and host already use, then pick the first match:

1. An orchestrator CLI present on PATH and referenced by the project or named by the user: `devpod`, `devsy`, `coder`, `devbox`, `gh codespace`.
2. The reference CLI, `devcontainer`. If missing: `npm install --prefix <scratch-dir> @devcontainers/cli` and call its `node_modules/.bin/devcontainer`.
3. Plain shell with `podman build` and `podman run` (image and Dockerfile configs only).

Two equally plausible orchestrators: ask once. Never install an orchestrator the user does not use.

## Orchestrators and editors

| Tool | Signal | Administration | Notes |
| --- | --- | --- | --- |
| DevPod | `devpod` on PATH | `devpod up <path> --devcontainer-path <file>`, `devpod up <ws> --recreate`, `devpod ssh <ws>`, `devpod delete <ws>` | Docker provider built in; Podman through a community provider. Does not support `userEnvProbe`, `waitFor`, parallel lifecycle scripts. |
| Devsy | `devsy` on PATH | Flags unverified: read `devsy --help` and `devsy up --help` before use | Implements the DevContainer standard, same workspace model as DevPod. |
| VS Code | `code` on PATH, `.vscode/` | No container administration CLI found; the Dev Containers extension reads `dev.containers.dockerPath` (`podman`) and `dev.containers.dockerComposePath` | Use the reference CLI to verify. |
| Cursor | `cursor` on PATH, `.cursor/` | Same extension settings as VS Code through Anysphere's Remote Containers | Agent window lacks Dev Containers; `cursor --classic` is the workaround. |
| JetBrains | `.idea/` | IDE-driven (gutter "Create Dev Container"); no CLI | Finds the standard locations and any folder; `customizations.jetbrains`. |
| Zed | `.zed/`, `zed` on PATH | Manual: set `use_podman: true` in Zed settings for Podman; no rebuild on config change, kill the container and reopen | Folder layout only. |
| Codespaces | `.github/` and a GitHub remote | Remote only; no local build | Reads `.devcontainer/devcontainer.json`, `.devcontainer.json`, or `.devcontainer/<SUBDIR>/devcontainer.json`. |
| Coder | `coder` on PATH, `~/.config/coder` | `coder templates init`, `coder create <template>`, `coder ssh <workspace>` | Infrastructure-as-code platform. Uses Terraform templates to spin up remote workspaces (Docker, Kubernetes, AWS, GCP, etc.) that can natively ingest and orchestrate `devcontainer.json` environments. |

An orchestrator offering no CLI means you continue with the reference CLI or shell. Report which editors the config was not tested in.

## Reference CLI flags

Observed in `devcontainer` 0.90.0 help:

- `up`: `--workspace-folder`, `--config`, `--docker-path`, `--docker-compose-path`, `--remove-existing-container`, `--build-no-cache`, `--skip-post-create`, `--include-configuration`, `--include-merged-configuration`.
- `exec`: `--workspace-folder`, `--docker-path`, `--docker-compose-path`, `--container-id`, `--remote-env`.
- Also present: `read-configuration`, `build`, `run-user-commands`, `outdated`, `upgrade`, `features`, `templates`, `set-up`. There is no `down`; stop containers through the runtime by label `devcontainer.local_folder=<workspace>`.

If `devcontainer` command exists, run `devcontainer <command> --help` when the version differs.

## Sources

- Reference CLI help (tool output, 0.90.0) and README: https://github.com/devcontainers/cli
- Podman rootless field in `podman info`: https://docs.podman.io/en/latest/markdown/podman-info.1.html
- Docker rootless Security Options entry: https://docs.docker.com/engine/security/rootless/
- DevPod devcontainer.json support: https://devpod.sh/docs/developing-in-workspaces/devcontainer-json
- Devsy: https://pkg.go.dev/github.com/devsy-org/devsy
- Zed: https://zed.dev/docs/dev-containers
- JetBrains: https://www.jetbrains.com/help/idea/connect-to-devcontainer.html
- Codespaces: https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers
- VS Code with Podman (community): https://oneuptime.com/blog/post/2026-03-18-use-podman-vscode-dev-containers/view
