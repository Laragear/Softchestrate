---
name: replicating-production-locally
description: Builds a local replica of a project's production deployment from its already decided architecture (IaC, deployment manifests, CI/CD deploy jobs, accepted ADRs, runbooks) so changes can be tested without touching production. Use when asked to mirror, simulate, emulate or reproduce production locally for web apps, mobile apps, ESP32 or other firmware daemons, network stacks, Linux drivers or services. Not for designing a new architecture, deploying to real infrastructure, generic dev environments unrelated to production, or projects with no recorded or validated architecture.
license: MIT
compatibility: Needs shell access to the project and the local machine. Any runtime used (container engine, VM, emulator, simulator) must be installed or installable by the user.
---

# Replicating production locally

Goal: a local setup that behaves like the decided production architecture, so tests carry no commitment to the real deployment.

Terms: **decided architecture** = what production is documented or configured to be, in validated sources. **Replica** = the local stand-in. **Gap** = any way the replica differs from production.

## Hard rules

- Replicate only what the evidence shows; never add, rename or "improve" a component.
- Never contact production: no production hosts, credentials, secrets, databases, tokens or signing keys. Use local placeholders.
- Never edit production files (deploy manifests, IaC, CI, production Dockerfiles or Compose files) unless the user says so. Put replica files in one new directory (default `local-replica/`) or where the user names.
- Never load kernel modules, change network or firewall settings, or flash hardware on the host without explicit approval in chat. Use an isolated VM, namespace or emulator.
- Every claim about a tool, flag or version needs a source: its `--help`, its docs, or a URL. If unverified, say so.
- Every inferred fact cites `path:line` or command output.
- No multiline comments in generated files.

## Workflow

Track: 1 prepare, 2 evidence gate, 3 inventory, 4 map, 5 plan and approval, 6 build, 7 verify, 8 report.

1. **Prepare.** If the project has a sources index (`sources/README.md`, `docs/DEPLOYMENT.md`), read it first and then the matching playbook; use the web only for what the index lacks and add findings to the sources files. Identify the target type and read the matching section of `references/target-types.md` (find it with `grep -n '^## '`, then read that range only). Check which runtimes are already installed before proposing any.
2. **Evidence gate.** Read `references/architecture-evidence.md`; locate sources and classify each as decided or not. Stop and report, without building, if: no deployment definition or architecture record exists; the architecture is only proposed, draft, TODO or contradicted by the deployed definition; or two sources conflict and the user has not chosen. Ask only what blocks progress.
3. **Inventory production.** One row per component: role, version or image pin, configuration source, network and port exposure, data stores, external dependencies, secrets (names only), startup order, each with `path:line` evidence.
4. **Map to local stand-ins**, per component, in this order: (1) the same artifact production runs (image, build, firmware, kernel version) with local configuration; (2) a compatible stand-in, recorded as a gap; (3) a stub for an external dependency that cannot run locally, recorded as a gap. Look up each chosen tool's current docs, cite the URL and read its `--help` before using flags. Choose the shell commands yourself.
5. **Plan and approval.** Present in chat the inventory, the mapping with gaps, the files to create, and anything needing privileges, installs, downloads or hardware. Wait for approval if any step installs software, needs privileges or substitutes a component; otherwise continue. A step only a human can perform (issuing credentials, walking a third-party dashboard, flashing hardware) becomes a short stage-gated checklist script instead of prose: one focused step per stage, a confirmation before anything irreversible, each captured value written where it belongs. The script is throwaway unless the user asks to keep it.
6. **Build in isolation.** Create files only in the replica location. Keep ports, volumes, networks and names distinct per project. Expose only the ports the application needs. Pin production's versions; where it has none, pin and record how "latest" was found. One documented command to start and one to tear down.
7. **Verify.** Per component, run a check and keep the output as receipt; then run one end-to-end path mirroring a real production path (request in, data stored, response out). On failure, diagnose and retry at most 3 times per component, then stop and report the blocker. Never claim success without a passing receipt; state what was not run.
8. **Report**, concisely: (1) result (running or blocked) and how to start and stop it; (2) component table: production source `path:line` | local stand-in | gap; (3) verification receipts and what was not verified; (4) gaps that could make local results differ; (5) sources: URLs for every tool fact used.
