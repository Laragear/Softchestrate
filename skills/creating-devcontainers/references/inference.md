# Inference with receipts

## Contents
- Rules
- Where each fact comes from
- Precedence
- Receipts table

## Rules

1. Every fact in the report cites a receipt from a file you read, or a command you ran.
2. A value you did not see is not a value. Mark it `unresolved` and ask.
3. Constraint is not version. `"php": "^8.3"` allows 8.3 and above; the base version comes from Phase 2's latest-version check inside that constraint.
4. `.env` files are never read. `.env.example` keys are evidence of services, values are ignored.

## Where each fact comes from

| Fact | Receipts, in order of strength |
| --- | --- |
| Language version | version files (`.php-version`, `.nvmrc`, `.node-version`, `.python-version`, `.ruby-version`, `.tool-versions`, `mise.toml`, `rust-toolchain*`, `go.mod`), then manifest constraint (`composer.json` `require.php`, `package.json` `engines.node`, `pyproject.toml` `requires-python`), then production `Dockerfile` `FROM`, then CI `*-version` keys |
| Package manager | `package.json` `packageManager`, then lockfile (`pnpm-lock.yaml`, `yarn.lock`, `bun.lock*`, `package-lock.json`, `composer.lock`, `uv.lock`, `poetry.lock`, `Pipfile.lock`, `Cargo.lock`, `go.sum`, `Gemfile.lock`) |
| Project type | framework package in the manifest (`laravel/framework`, `next`, `vite`, `django`, `rails`), then entrypoint files |
| Deploy host | platform config (`vercel.json`, `fly.toml`, `netlify.toml`, `wrangler.*`, `railway.json`, `render.yaml`, `Procfile`), `Dockerfile` or Compose or Kubernetes manifests, CI deploy jobs |
| Required services | local Compose `image:` lines, `.env.example` keys (`DB_*`, `REDIS_*`, `MAIL_*`, `SCOUT_*`, `TYPESENSE_*`), CI `services:` images, framework manifest drivers |
| System tooling | production `Dockerfile` install lines (`apt-get install`, `docker-php-ext-install`, `install-php-extensions`), manifest `ext-*` requirements, CI setup steps and `extensions:` |
| Editor extensions | `.vscode/extensions.json` entries, only when the user uses that editor |
| Host runtime | CLIs on PATH (`command -v`), `podman info` / `docker info` output (Phase 1) |

"Host" in a brief means the deploy host unless the user says otherwise; report both.

## Precedence

When two receipts for the same fact disagree:

1. Version file or lockfile over manifest constraint.
2. Manifest constraint over `Dockerfile`, over CI.
3. If production `Dockerfile` and a version file differ, the production value wins only when the user chose to mirror production in Phase 3.

Record the losing receipt in the table's Source column. If precedence cannot settle it (two version files disagree), ask.

## Receipts table

| Fact | Value | Source |
| --- | --- | --- |
| PHP | 8.4 (latest within `^8.3`) | `composer.json:12`; latest: <registry or release URL> |
| Package manager | pnpm 9.1.0 | `package.json:7` |
| Service | PostgreSQL 16 | `docker-compose.yml:21` |
