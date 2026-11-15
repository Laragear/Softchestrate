---
name: deploying-builds
description: Deploys, ships, releases, publishes or rolls out a build to a detected destination (Vercel, Netlify, Cloudflare, Fly.io, Railway, Render, Kubernetes, container registries, static hosts, VPS, CI-triggered pipelines), verifies the live result and rolls back on explicit instruction. Use when the user asks to deploy, ship, release, publish, roll out, verify or roll back a deployment. Not for writing code, running test suites, diagnosing failed builds or starting local dev servers.
license: MIT
compatibility: Needs shell access, the destination's CLI or deployment MCP server, write access to .agents/plans/, and ideally a way to dispatch sub-agents (otherwise tasks run inline and verification is capped at PARTIAL).
---

# Deploying builds

Take a finished build to its destination and prove it works there. Never write code, run test suites or improvise a deploy. A wrong deploy costs more than a delayed one, so doubt stops the line. Start only when the user explicitly asked to deploy, verify or roll back.

You orchestrate: you hold the plan, the gates and the report; sub-agents run the tasks.

Terms: **deployment** = one build going to one destination, from plan to verified result. **task** = one row of the plan's Tasks table, one sub-agent dispatch each. **channel** = how a task reaches the destination: MCP tool, CLI or API.

## Modes

| Mode | Required input | State changes | OK means |
| --- | --- | --- | --- |
| Deploy (default) | build and target | yes, after the gates | every task DONE, every check PASS |
| Assess only | build and target | none | plan validated and `ready` |
| Verify only | deploy-id and revision | none | every check PASS |
| Roll back | deploy-id, revision and what to roll back, stated by the user | yes, same gates | every task DONE, every check PASS |

STATUS: `OK` (see table); `PARTIAL` (state known, but a task was skipped or verification was not independent); `FAILED` (a task failed, or a check still fails after the plan's limits); `NEEDS_INPUT` (a decision or approval is needed, the report carries the question); `INVALID_BRIEF` (not a deployment request).

## Gates, in order, before any state change

1. **Destination** detected from evidence (Phase 1). None or two plausible: stop and ask.
2. **Tier** (preview, staging or production) from evidence. If it cannot be evidenced, treat it as production.
3. **Authorization.** Preview and staging proceed when the brief names them. Production needs the user's approval of the exact plan revision (Phase 2). Enthusiasm in the prompt is not approval.
4. **Plan** validated and `ready`.

## Phase 1: detect the destination

Read the repository's own signals: `vercel.json`, `fly.toml`, `netlify.toml`, `wrangler.*`, `railway.json`, `render.yaml`, `Procfile`, `Dockerfile`, Compose and Kubernetes manifests, CI deploy jobs, and the CLIs and MCP servers you can see. For the chosen platform, read its current docs or `--help` for how to authenticate, set secrets and query the live version; cite the URL.

Pick a channel per task: a deployment MCP server first, then the platform CLI, then a direct API call. Resolve MCP tool names from the live tool list and record each as `ServerName:tool_name`. Report any fallback. No channel: stop and ask.

CI-triggered destinations: the trigger (push or tag) is itself a Ship task. Name the channel (`git` or `gh`) and the exact ref; it needs the same authorization as any state change.

## Phase 2: assess the plan

Write `.agents/plans/deploy-{id}.md` (kebab-case id, `revision` starting at 1) with:

- **Header:** revision, status (`draft|ready|executing|blocked|complete`), destination with evidence path, tier with evidence, build identity (version or hash).
- **Tasks table:** per task a number, role (Prepare, Ship or Verify), channel, scope and acceptance criteria.
- **Checks:** each with its expected value, built so it can fail (see Phase 4), plus `limits` (retries, timeouts, interval).
- **Secrets:** names only, with the native tool that sets each.
- **Rollback:** the concrete path for every state-changing task, or `none, irreversible` stated.
- **Destructive actions:** teardown, data migration, force-promote, cache or CDN purge, each named, or `none`.
- **Assumptions:** every unverified detail, labeled.

Mark `ready` only when: destination and tier are evidenced; every task has a channel and acceptance criteria; every check names an expected value and has limits; secrets are names with a native way to set them; a rollback path exists for each state-changing task; destructive actions are named or `none`; no secret value appears anywhere in the plan (scan it for tokens, keys and `user:pass@` URLs). Fix and recheck on any failure.

Production approval: return `STATUS: NEEDS_INPUT` with the plan path, revision and a one-paragraph summary. Proceed only when the brief says `authorized <deploy-id> rev <N>` for the current revision. Any plan edit bumps the revision and voids earlier approval. Assess-only mode stops here.

## Phase 3: dispatch

One task per dispatch, each starting from a fresh context window. Each brief is self-contained: the plan (inline, or a path to read in full first), the task's scope, the channel, the destination evidence and the acceptance criteria. "See above" is not context.

| Task | Brief to the sub-agent | Constraint |
| --- | --- | --- |
| Prepare | Run the build or packaging commands and pin the artifact hash | A needed code change goes back to the parent |
| Ship | Use only the plan's channel, in the plan's order | The only place state changes |
| Verify | Run the plan's checks and return evidence | Read-only; a separate dispatch with clean context from Ship |

The shipper never verifies its own work. Without a way to dispatch sub-agents (or when depth limits hide it), run the tasks yourself, one at a time, under the same gates; mark verification `self-verified`, cap STATUS at `PARTIAL` and ask the user to confirm.

## Phase 4: verify

Every check comes from the plan and can fail.
- **Pin check:** the deployed artifact matches the pinned hash or version, queried through the channel until the platform reports it. Exit code 0 is not evidence.
- **Health check:** the plan's smoke criteria (status, content, header). Recheck after the platform reports healthy; one request can lie.
- **Log scan:** boot and startup errors for the new version.

A check still failing after the plan's limits means FAILED. Flaky-looking failures also trigger a stop.

## Secrets

A secret is anything that authenticates or grants access.
- Set secrets only with the platform's native tool (`gh secret set`, `wrangler secret put`, `vercel env add`, `fly secrets set`, `kubectl create secret`, `aws secretsmanager put-secret-value`, or the platform MCP server's secrets tool).
- Value sources, in order: (a) already in the platform store; (b) an environment variable the user set outside this session, passed through stdin or a file descriptor if supported, never as a command argument; (c) the user sets it themselves. Sub-agents cannot prompt the user.
- Never put a value in a brief, plan, manifest, log, report, repository file or container image. Scan every report draft for values before sending. A leaked value is an incident even when the deployment is green: stop and recommend rotation.
- A missing or mismatched secret is a stop: no placeholders, empty values or temporary plaintext.

## When to stop

Stop dispatching and ask when: the destination or credentials are uncertain, or auth fails unexpectedly; the same platform error repeats or errors contradict each other; whether the deployment is live has no evidence, or the rollout is partial; the method conflicts with the destination evidence; a required secret is missing, mismatched or cannot be set natively; something has shipped and the rollback path is unclear; timeouts, rate limits or statuses are intermittent.

Then stop pending tasks, snapshot what shipped and what the last evidence says, and offer concrete options (retry, roll back, abort, investigate). Ask directly if a user channel exists, otherwise report `NEEDS_INPUT`. Never choose silently, retry beyond the plan's limits, or roll back on your own.

## Hard rules

- No state-changing call before the plan is `ready` and, for production, approved at the current revision.
- Never edit application code, run test suites or fix builds; hand those back to the parent.
- Destructive actions run only when the plan names them and the user approved that revision.
- The plan file is canonical and current; the report matches it.

## Report format

Copy exactly.

```
STATUS: OK | PARTIAL | FAILED | NEEDS_INPUT | INVALID_BRIEF
DESTINATION: <platform / target> (tier: <preview|staging|production>) — evidence: <path or tool>
PLAN: <path> rev <N> — status: <draft|ready|executing|blocked|complete>
CHANNEL: <ServerName:tool_name | CLI | API> (per task, if mixed)
TASKS:
1. <task> — <role> — DONE|FAILED — evidence: <url | hash | path:line>
SECRETS: <NAME — <native tool> — set|already-present|skipped> (values never reported)
VERIFY: <check — PASS|FAIL — evidence> (independent | self-verified)
STOPPED: <what made it stop and what the user decided, or "pending user", or "none">
NEEDS FROM USER: <question + options, or "none">
```
