# Source register

Every fact in `references/` cites an ID from this table. Fetched 2026-11-04. Re-fetch only when a fact looks stale; the markdown endpoints (`.md` suffix) of Anthropic and agentskills.io docs return clean text.

Tier order, strongest first: **A** authority (specs, vendor docs, vendor engineering posts) → **B** research (papers, measured studies) → **C** named experts → **D** community. When tiers disagree the higher tier wins; the disagreement is logged in `rules.md` § Tensions.

Read depth: *full* = read end to end, *part* = relevant sections only, *abstract* = abstract page only, *secondary* = read through a summary of the original.

## A. Authority

| ID | Source | URL | Depth |
| --- | --- | --- | --- |
| A1 | Agent Skills specification | https://agentskills.io/specification.md | full |
| A2 | Agent Skills: best practices for skill creators | https://agentskills.io/skill-creation/best-practices.md | full |
| A3 | Agent Skills: optimizing skill descriptions | https://agentskills.io/skill-creation/optimizing-descriptions.md | full |
| A4 | Agent Skills: evaluating skill output quality | https://agentskills.io/skill-creation/evaluating-skills.md | part |
| A5 | Agent Skills: using scripts in skills | https://agentskills.io/skill-creation/using-scripts.md | part |
| A6 | Agent Skills: adding skills support to an agent (client guide) | https://agentskills.io/client-implementation/adding-skills-support.md | part |
| A7 | `skills-ref` reference validator, `validator.py` and `parser.py` | https://github.com/agentskills/agentskills/tree/main/skills-ref/src/skills_ref | full |
| A8 | Anthropic: Skill authoring best practices | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | full |
| A9 | Anthropic: Agent Skills overview | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | part |
| A10 | Claude Code: Extend Claude with skills | https://code.claude.com/docs/en/skills | part |
| A11 | Claude Code: Create custom subagents | https://code.claude.com/docs/en/sub-agents | part |
| A12 | Claude Code: Best practices | https://code.claude.com/docs/en/best-practices | part |
| A13 | Anthropic: Prompting best practices for Claude | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices | part |
| A14 | Anthropic Engineering: Equipping agents for the real world with Agent Skills | https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills | full |
| A15 | Anthropic Engineering: Effective context engineering for AI agents | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | part |
| A16 | Anthropic Engineering: How we built our multi-agent research system | https://www.anthropic.com/engineering/multi-agent-research-system | part |
| A17 | Anthropic Engineering: Building effective agents | https://www.anthropic.com/engineering/building-effective-agents | fetched, not read in depth; no rule depends on it |
| A18 | Anthropic Engineering: Writing tools for agents | https://www.anthropic.com/engineering/writing-tools-for-agents | fetched, not read in depth; no rule depends on it |
| A19 | `anthropics/skills`: `skill-creator/SKILL.md` | https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md | part |
| A20 | OpenAI Codex: Agent Skills | https://developers.openai.com/codex/skills | part |
| A21 | OpenAI Codex: AGENTS.md guide | https://developers.openai.com/codex/guides/agents-md | part |
| A22 | agents.md (open format) | https://agents.md/ | part |
| A23 | Gemini CLI: Creating Agent Skills | https://geminicli.com/docs/cli/creating-skills.md | part |
| A24 | Zed: Skills | https://zed.dev/docs/ai/skills.md | part |
| A25 | Digital.gov (US GSA), Plain language guide: principles, writing, clear-short, style, design/lists, design/tables (successor of plainlanguage.gov) | https://digital.gov/guides/plain-language/ | full for principles, writing, lists, tables; first 2,600 chars of clear-short and style |
| A26 | Google developer documentation style guide: highlights, procedures | https://developers.google.com/style/highlights | part |
| A28 | Federal Plain Language Guidelines (March 2011) and National Archives plain-writing principles, archived copies | https://webarchive.library.unt.edu/web/20120915090932/http:/www.plainlanguage.gov/howto/guidelines/FederalPLGuidelines/TOC.cfm | search-result summaries only |
| A27 | ISO 24495-1:2023, Plain language, governing principles and guidelines | https://www.standards.govt.nz/shop/iso-24495-12023 (catalogue page; also https://www.iplfederation.org/the-iso-plain-language-standard-part1) | search-result summaries only; standard text not read (paywalled) |

## B. Research

| ID | Source | URL | Depth |
| --- | --- | --- | --- |
| B1 | Gloaguen et al., *Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* (arXiv 2602.11988, v3 Sep 2026) | https://arxiv.org/abs/2602.11988 | abstract + intro |
| B2 | Li et al., *SkillsBench* (arXiv 2602.12670, v4 Jun 2026) | https://arxiv.org/abs/2602.12670 | abstract + results tables |
| B3 | Han et al., *SWE-Skills-Bench* (arXiv, Mar 2026) | https://liner.com/review/sweskillsbench-do-agent-skills-actually-help-in-realworld-software-engineering | secondary (quick review of the abstract) |
| B4 | Yang and Ding, *Signal or Noise? A Benchmark Study of Agent Skills in Web Development* (arXiv 2608.23067, Aug 2026) | https://arxiv.org/abs/2608.23067 | abstract |
| B5 | Liu et al., *Lost in the Middle* (arXiv 2307.03172, TACL 2023) | https://arxiv.org/abs/2307.03172 | abstract |
| B6 | Chroma Research, *Context Rot* | https://research.trychroma.com/context-rot | part |
| B7 | Sweller, cognitive load theory (split-attention and redundancy effects; Chandler and Sweller 1991, 1992; Sweller 2011) | secondary: teaching-resource summaries returned by web search; primary papers not retrieved | secondary |

## C. Experts

| ID | Source | URL | Depth |
| --- | --- | --- | --- |
| C1 | Simon Willison, *Claude Skills are awesome, maybe a bigger deal than MCP* (2025-10-16) | https://simonwillison.net/2025/Oct/16/claude-skills/ | full |
| C2 | Yichao Ji (Manus), *Context Engineering for AI Agents: Lessons from Building Manus* | https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus | part |
| C3 | Walden Yan (Cognition), *Don't Build Multi-Agents* (2025-06) | https://cognition.com/blog/dont-build-multi-agents | part |
| C4 | Cognition, *Multi-Agents: What's Actually Working* (2026-04) | https://cognition.com/blog/multi-agents-working | part |
| C5 | Drew Breunig, *How Long Contexts Fail* (2025-06-22) | https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html | full |
| C6 | Jesse Vincent (obra), `superpowers` skill `writing-skills` | https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md | full |

## D. Community

| ID | Source | URL | Depth |
| --- | --- | --- | --- |
| D1 | claudefa.st, *Skill listing budget* (third-party blog; its settings were later documented by A10) | https://claudefa.st/blog/guide/mechanics/skill-listing-budget | part |
| D3 | Chisle plugin v3.8.1, `skills/chisle/SKILL.md`, `skills/chisle-audit/SKILL.md`, `rules/chisle-activate.md` (named by the maintainer as the prose reference; local copy under the user's plugin cache) | local files | full |
| D2 | Mario Zechner, `pi` coding agent: skills doc | https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/skills.md | part |

Not used: search-engine summaries of pages that were not fetched. Several 2026 arXiv IDs surfaced in searches were only cited here after the abstract page itself was fetched (B1, B2, B4).
