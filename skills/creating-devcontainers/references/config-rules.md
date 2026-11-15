# Configuration rules

## Contents
- Format and comments
- Image and user
- UID/GID matching
- Compose
- Ports and socat
- Lifecycle
- Editor customizations
- Sources

## Format and comments

- `devcontainer.json` is JSON with Comments. Use `//` on its own line only for a non-obvious choice. No `/* */`, no comment blocks, no commented-out options.
- Dockerfile and shell: one-line `#` comments at most. Less is better.
- Paths in `build.dockerfile`, `build.context` and `dockerComposeFile` resolve relative to the folder holding `devcontainer.json`.

## Image and user

- Base: Docker Official `debian` or `ubuntu` (latest stable or LTS that satisfies the project), or the official language image when the project's version receipts name one. Do not use `mcr.microsoft.com/devcontainers/*`.
- Pin by tag (`debian:trixie-slim`, `php:8.4-cli-trixie`), never `latest`. Record the registry tag listing or release page URL used for the choice.
- Non-root user is mandatory. Dockerfile route: `groupadd` and `useradd` with fixed UID and GID 1000. Image-only route: Feature `ghcr.io/devcontainers/features/common-utils:2` with `username`, `userUid`, `userGid`. Report that Feature as a dependency from the spec's own registry.
- Check an official image's existing users before adding one: `<runtime> run --rm <image> getent passwd 1000`.
- Install only receipts-backed tooling. Add `socat` only when Phase 4 needs it (see Ports).

## UID/GID matching

Goal: the container user and its files match the host user that spawned the container, so the project is writable. Choose by runtime, then verify (Phase 5 is the arbiter).

| Runtime | Setting |
| --- | --- |
| Podman rootless (default choice) | `"runArgs": ["--userns=keep-id:uid=<U>,gid=<G>"]`, `containerUser` and `remoteUser` set to the image user, `"updateRemoteUserUID": false`. `<U>`/`<G>` are the image user's IDs. This maps the host user onto the image user whatever the host UID is. |
| Docker rootful | `containerUser`/`remoteUser` set to the non-root user and `"updateRemoteUserUID": true`; the spec updates the image user to the local UID/GID on Linux. |
| Docker rootless | Unverified in sources. Start with the Docker rootful setting, run the ownership test, and switch only if it fails. Report what passed. |

Compose projects cannot use `runArgs`. Set `userns_mode: "keep-id"` (Podman) and `user:` on the dev service in the override file. If the Compose provider rejects `keep-id:uid=,gid=`, use build args `USER_UID` and `USER_GID` fed from the host IDs with a default of 1000, and rerun the ownership test.

SELinux hosts (`getenforce` reports Enforcing): add `"--security-opt","label=disable"` to `runArgs`, or `:z` on Compose bind mounts, and verify.

## Compose

- Reuse the project's local Compose file by listing it first and an override second:
  `"dockerComposeFile": ["../docker-compose.yml", "docker-compose.devcontainer.yml"]`. The override lives in `.devcontainer/` and carries the dev service, user mapping and ports. Never edit the project's file.
- `service` names the dev service. It must stay alive: `command: sleep infinity` in the override.
- Ports use variables with defaults: `"${APP_PORT:-8000}:8000"`.
- `shutdownAction` defaults to `stopCompose`; leave it.

## Ports and socat

Backing-service ports (search engine, admin panels, database UIs) are not published on the host by Compose. Proxy them through the dev container instead:

1. Install `socat` in the dev image.
2. For each service port the host needs, start a background proxy in `postStartCommand`:
   `"postStartCommand": "nohup socat TCP-LISTEN:8108,fork,reuseaddr TCP:typesense:8108 >/dev/null 2>&1 &"`
   Chain several with `; `.
3. List the same ports in `forwardPorts`.

Zed's docs list only `appPort` as supported; when Zed is in the receipts, publish the app ports on the dev service in the override with the same `${VAR:-default}` pattern instead of `forwardPorts`.

## Lifecycle

- Dependency install goes in `postCreateCommand`, derived from the lockfile receipt (`composer install`, `pnpm install --frozen-lockfile`, `npm ci`, `uv sync`, `bundle install`). No lockfile, no install command.
- Prefer the string or array form of one command; use the object form only for work that is truly independent and each entry must exit 0.
- Avoid `initializeCommand`: it runs on the host.
- A second artifact is justified only by a script too long for one line.

## Editor customizations

Default: none. Add `customizations.<editor>` only for an editor with a receipt (`.vscode/extensions.json` IDs for VS Code or Cursor, `customizations.jetbrains.backend` for JetBrains, `customizations.zed.extensions` for Zed), copying values from that receipt.

## Sources

- Spec, locations, merge logic, UID/GID sync, lifecycle: https://containers.dev/implementors/spec/
- `forwardPorts`, `appPort`, `shutdownAction`, `overrideCommand`: https://containers.dev/implementors/json_reference/
- Podman `--userns` keep-id: https://docs.podman.io/en/v4.6.0/markdown/options/userns.container.html
- common-utils Feature options: https://github.com/devcontainers/features/tree/main/src/common-utils
- Zed port and location notes: https://zed.dev/docs/dev-containers
- Compose override and port-collision rationale (community): Microsoft Compose sample pattern, https://codex.devs.constructions-3d.com/decisions/2026-04-21-devcontainer-port-exposure
